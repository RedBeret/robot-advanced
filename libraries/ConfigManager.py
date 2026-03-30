"""Environment configuration manager for Robot Framework."""

import os
import yaml
from pathlib import Path
from robot.api.deco import keyword
from robot.api import logger


class ConfigManager:
    """Multi-environment configuration loader."""

    ROBOT_LIBRARY_SCOPE = "GLOBAL"

    def __init__(self, env: str = None):
        self._env = env or os.environ.get("RF_ENV", "dev")
        self._config = {}
        self._load_config()

    def _load_config(self):
        config_dir = Path(__file__).parent.parent / "config" / self._env
        config_file = config_dir / "config.yaml"
        if config_file.exists():
            with open(config_file) as f:
                self._config = yaml.safe_load(f) or {}
            logger.info(f"Loaded config for environment: {self._env}")
        else:
            logger.warning(f"No config.yaml found for environment: {self._env}")

    @keyword("Get Config Value")
    def get_config_value(self, key: str, default: str = None) -> str:
        parts = key.split(".")
        value = self._config
        for part in parts:
            if isinstance(value, dict) and part in value:
                value = value[part]
            else:
                return default
        return str(value) if value is not None else default

    @keyword("Get Current Environment")
    def get_current_environment(self) -> str:
        return self._env

    @keyword("Switch Environment")
    def switch_environment(self, env: str):
        self._env = env
        self._config = {}
        self._load_config()

    @keyword("Config Should Have Key")
    def config_should_have_key(self, key: str):
        value = self.get_config_value(key)
        if value is None:
            raise AssertionError(f"Config missing key: {key}")
