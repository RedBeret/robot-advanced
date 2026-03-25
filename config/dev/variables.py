"""Dev environment variables for Robot Framework.

Load with: robot --variablefile config/dev/variables.py tests/
"""

# API Configuration
API_BASE_URL = "https://jsonplaceholder.typicode.com"
API_TIMEOUT = 30

# Database
DB_HOST = "localhost"
DB_PORT = 5432
DB_NAME = "testdb_dev"

# Feature Flags
ENABLE_BROWSER_TESTS = True
ENABLE_PERFORMANCE_TESTS = True
LOG_LEVEL = "DEBUG"

# Environment identifier
ENV_NAME = "dev"
