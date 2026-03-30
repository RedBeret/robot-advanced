"""Production-grade REST API test framework for Robot Framework."""

import json
import time
from urllib.request import Request, urlopen
from urllib.error import HTTPError, URLError
from robot.api.deco import keyword
from robot.api import logger


class APIFramework:
    """REST API testing framework with session management."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    def __init__(self, base_url: str = "https://jsonplaceholder.typicode.com"):
        self._base_url = base_url.rstrip("/")
        self._headers = {"Content-Type": "application/json", "Accept": "application/json"}
        self._last_response = None
        self._session_vars = {}

    @keyword("Set Base URL")
    def set_base_url(self, url: str):
        self._base_url = url.rstrip("/")

    @keyword("Set Auth Header")
    def set_auth_header(self, token: str, scheme: str = "Bearer"):
        self._headers["Authorization"] = f"{scheme} {token}"

    @keyword("Set Custom Header")
    def set_custom_header(self, name: str, value: str):
        self._headers[name] = value

    @keyword("GET")
    def get(self, path: str, expected_status: int = 200) -> dict:
        return self._request("GET", path, expected_status=expected_status)

    @keyword("POST")
    def post(self, path: str, body: dict = None, expected_status: int = 201) -> dict:
        return self._request("POST", path, body=body, expected_status=expected_status)

    @keyword("PUT")
    def put(self, path: str, body: dict = None, expected_status: int = 200) -> dict:
        return self._request("PUT", path, body=body, expected_status=expected_status)

    @keyword("DELETE")
    def delete(self, path: str, expected_status: int = 200) -> dict:
        return self._request("DELETE", path, expected_status=expected_status)

    @keyword("Get Last Response")
    def get_last_response(self) -> dict:
        return self._last_response

    @keyword("Save Response Value")
    def save_response_value(self, key: str, json_path: str):
        value = self._extract_json_path(self._last_response["body"], json_path)
        self._session_vars[key] = value
        logger.info(f"Saved {key} = {value}")

    @keyword("Get Saved Value")
    def get_saved_value(self, key: str):
        if key not in self._session_vars:
            raise ValueError(f"No saved value for key: {key}")
        return self._session_vars[key]

    @keyword("Response Should Contain Key")
    def response_should_contain_key(self, key: str):
        body = self._last_response["body"]
        if isinstance(body, dict) and key not in body:
            raise AssertionError(f"Response missing key: {key}\nBody: {json.dumps(body, indent=2)[:500]}")

    @keyword("Response Value Should Be")
    def response_value_should_be(self, json_path: str, expected):
        actual = self._extract_json_path(self._last_response["body"], json_path)
        if str(actual) != str(expected):
            raise AssertionError(f"Expected {json_path} = {expected}, got {actual}")

    @keyword("Response Time Should Be Below")
    def response_time_should_be_below(self, max_ms: int):
        actual = self._last_response["duration_ms"]
        if actual > int(max_ms):
            raise AssertionError(f"Response took {actual}ms, limit is {max_ms}ms")

    def _request(self, method, path, body=None, expected_status=200, retries=2):
        url = f"{self._base_url}{path}"
        data = json.dumps(body).encode() if body else None
        req = Request(url, data=data, headers=dict(self._headers), method=method)
        start = time.monotonic()
        for attempt in range(retries + 1):
            try:
                with urlopen(req, timeout=30) as resp:
                    resp_body = json.loads(resp.read())
                    duration_ms = int((time.monotonic() - start) * 1000)
                    self._last_response = {
                        "status": resp.status, "body": resp_body,
                        "headers": dict(resp.headers), "duration_ms": duration_ms,
                        "url": url, "method": method,
                    }
                    logger.info(f"{method} {path} -> {resp.status} ({duration_ms}ms)")
                    if resp.status != expected_status:
                        raise AssertionError(f"Expected status {expected_status}, got {resp.status}")
                    return self._last_response
            except HTTPError as e:
                duration_ms = int((time.monotonic() - start) * 1000)
                self._last_response = {
                    "status": e.code, "body": {},
                    "headers": dict(e.headers) if e.headers else {},
                    "duration_ms": duration_ms, "url": url, "method": method,
                }
                if e.code >= 500 and attempt < retries:
                    time.sleep(1)
                    continue
                if e.code != expected_status:
                    raise AssertionError(f"Expected status {expected_status}, got {e.code}")
                return self._last_response
            except URLError:
                if attempt < retries:
                    time.sleep(1)
                    continue
                raise

    @staticmethod
    def _extract_json_path(data, path):
        parts = path.split(".")
        current = data
        for part in parts:
            if isinstance(current, dict):
                current = current[part]
            elif isinstance(current, list):
                current = current[int(part)]
            else:
                raise ValueError(f"Cannot navigate '{part}' in {type(current)}")
        return current
