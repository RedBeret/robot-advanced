"""Retry and circuit breaker patterns for Robot Framework.

Real-world tests deal with flaky services, network issues, and
eventual consistency. This library provides resilient execution patterns.
"""

import time
from robot.api.deco import keyword
from robot.api import logger


class RetryLibrary:
    """Retry, backoff, and circuit breaker keywords."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self):
        self._circuit_breakers = {}

    @keyword("Retry Keyword")
    def retry_keyword(self, keyword_name: str, *args, retries: int = 3,
                      delay: float = 1.0, backoff: float = 2.0):
        """Retry a keyword with exponential backoff.

        Arguments:
        - keyword_name: Name of the keyword to retry
        - retries: Maximum number of retry attempts
        - delay: Initial delay between retries (seconds)
        - backoff: Multiplier for delay on each retry
        """
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
                    logger.warn(
                        f"Attempt {attempt + 1} failed: {e}. "
                        f"Retrying in {current_delay}s..."
                    )
                    time.sleep(current_delay)
                    current_delay *= float(backoff)

        raise AssertionError(
            f"Keyword '{keyword_name}' failed after {int(retries) + 1} attempts. "
            f"Last error: {last_error}"
        )

    @keyword("Wait Until Keyword Succeeds With Backoff")
    def wait_until_succeeds(self, timeout: float, keyword_name: str, *args):
        """Keep retrying a keyword until it succeeds or timeout expires."""
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
                    raise AssertionError(
                        f"Timed out after {timeout}s ({attempt} attempts). Last: {e}")
                time.sleep(min(delay, remaining))
                delay = min(delay * 1.5, 10)

    @keyword("Initialize Circuit Breaker")
    def init_circuit_breaker(self, name: str, failure_threshold: int = 3,
                             reset_timeout: float = 30.0):
        """Create a circuit breaker for a service."""
        self._circuit_breakers[name] = {
            "failures": 0,
            "threshold": int(failure_threshold),
            "reset_timeout": float(reset_timeout),
            "state": "closed",
            "last_failure": 0,
        }

    @keyword("Execute With Circuit Breaker")
    def execute_with_circuit_breaker(self, name: str, keyword_name: str, *args):
        """Execute a keyword through a circuit breaker."""
        from robot.libraries.BuiltIn import BuiltIn
        bi = BuiltIn()
        cb = self._circuit_breakers.get(name)
        if not cb:
            raise ValueError(f"No circuit breaker named '{name}'")

        # Check if circuit is open
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
                logger.warn(f"Circuit '{name}' is now OPEN after {cb['failures']} failures")
            raise

    @keyword("Get Circuit Breaker State")
    def get_circuit_breaker_state(self, name: str) -> str:
        cb = self._circuit_breakers.get(name)
        if not cb:
            raise ValueError(f"No circuit breaker named '{name}'")
        return cb["state"]
