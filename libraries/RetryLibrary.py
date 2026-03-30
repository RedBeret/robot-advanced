"""Retry and circuit breaker patterns for Robot Framework."""

import time
from robot.api.deco import keyword
from robot.api import logger


class RetryLibrary:
    """Retry, backoff, and circuit breaker keywords."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self._circuit_breakers = {}

    @keyword("Retry Keyword")
    def retry_keyword(self, keyword_name, *args, retries=3, delay=1.0, backoff=2.0):
        from robot.libraries.BuiltIn import BuiltIn
        bi = BuiltIn()
        last_error = None
        current_delay = float(delay)
        for attempt in range(int(retries) + 1):
            try:
                result = bi.run_keyword(keyword_name, *args)
                if attempt > 0:
                    logger.info(f"Keyword '{keyword_name}' succeeded on attempt {attempt + 1}")
                return result
            except Exception as e:
                last_error = e
                if attempt < int(retries):
                    logger.warning(f"Attempt {attempt + 1} failed: {e}. Retrying in {current_delay}s...")
                    time.sleep(current_delay)
                    current_delay *= float(backoff)
        raise AssertionError(f"Keyword '{keyword_name}' failed after {int(retries) + 1} attempts. Last error: {last_error}")

    @keyword("Wait Until Keyword Succeeds With Backoff")
    def wait_until_succeeds(self, timeout, keyword_name, *args):
        from robot.libraries.BuiltIn import BuiltIn
        bi = BuiltIn()
        deadline = time.time() + float(timeout)
        attempt = 0
        delay = 0.5
        while time.time() < deadline:
            attempt += 1
            try:
                return bi.run_keyword(keyword_name, *args)
            except Exception as e:
                remaining = deadline - time.time()
                if remaining <= 0:
                    raise AssertionError(f"Timed out after {timeout}s ({attempt} attempts). Last: {e}")
                time.sleep(min(delay, remaining))
                delay = min(delay * 1.5, 10)

    @keyword("Initialize Circuit Breaker")
    def init_circuit_breaker(self, name, failure_threshold=3, reset_timeout=30.0):
        self._circuit_breakers[name] = {
            "failures": 0, "threshold": int(failure_threshold),
            "reset_timeout": float(reset_timeout), "state": "closed", "last_failure": 0,
        }

    @keyword("Execute With Circuit Breaker")
    def execute_with_circuit_breaker(self, name, keyword_name, *args):
        from robot.libraries.BuiltIn import BuiltIn
        bi = BuiltIn()
        cb = self._circuit_breakers.get(name)
        if not cb:
            raise ValueError(f"No circuit breaker named '{name}'")
        if cb["state"] == "open":
            if time.time() - cb["last_failure"] > cb["reset_timeout"]:
                cb["state"] = "half-open"
                logger.info(f"Circuit '{name}' transitioning to half-open")
            else:
                raise AssertionError(f"Circuit '{name}' is OPEN — not executing")
        try:
            result = bi.run_keyword(keyword_name, *args)
            cb["failures"] = 0
            cb["state"] = "closed"
            return result
        except Exception as e:
            cb["failures"] += 1
            cb["last_failure"] = time.time()
            if cb["failures"] >= cb["threshold"]:
                cb["state"] = "open"
                logger.warning(f"Circuit '{name}' is now OPEN after {cb['failures']} failures")
            raise

    @keyword("Get Circuit Breaker State")
    def get_circuit_breaker_state(self, name):
        cb = self._circuit_breakers.get(name)
        if not cb:
            raise ValueError(f"No circuit breaker named '{name}'")
        return cb["state"]
