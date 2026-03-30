"""GraphQL client library for Robot Framework."""

import json
from urllib.request import Request, urlopen
from robot.api.deco import keyword
from robot.api import logger


class GraphQLClient:
    """GraphQL testing library."""

    ROBOT_LIBRARY_SCOPE = "SUITE"

    def __init__(self, endpoint: str = "https://countries.trevorblades.com/graphql"):
        self._endpoint = endpoint
        self._headers = {"Content-Type": "application/json"}
        self._last_result = None

    @keyword("Set GraphQL Endpoint")
    def set_endpoint(self, endpoint: str):
        self._endpoint = endpoint

    @keyword("Execute GraphQL Query")
    def execute_query(self, query: str, variables: dict = None) -> dict:
        payload = {"query": query}
        if variables:
            payload["variables"] = variables
        data = json.dumps(payload).encode()
        req = Request(self._endpoint, data=data, headers=self._headers)
        with urlopen(req, timeout=30) as resp:
            result = json.loads(resp.read())
        self._last_result = result
        if "errors" in result:
            errors = json.dumps(result["errors"], indent=2)
            logger.warn(f"GraphQL errors: {errors}")
        return result.get("data", {})

    @keyword("Execute GraphQL Mutation")
    def execute_mutation(self, mutation: str, variables: dict = None) -> dict:
        return self.execute_query(mutation, variables)

    @keyword("GraphQL Response Should Not Have Errors")
    def response_should_not_have_errors(self):
        if self._last_result and "errors" in self._last_result:
            raise AssertionError(
                f"GraphQL returned errors: {json.dumps(self._last_result['errors'], indent=2)}")

    @keyword("Get GraphQL Field")
    def get_field(self, *path) -> object:
        data = self._last_result.get("data", {})
        for key in path:
            if isinstance(data, dict):
                data = data[key]
            elif isinstance(data, list):
                data = data[int(key)]
        return data
