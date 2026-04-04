# Robot Framework Advanced

![Robot Framework](https://img.shields.io/badge/Robot_Framework-green?logo=robotframework&logoColor=white) ![License: MIT](https://img.shields.io/badge/License-MIT-green) ![GitHub stars](https://img.shields.io/github/stars/RedBeret/robot-advanced?style=social)


Production-grade Robot Framework techniques: custom test frameworks, API testing, Docker, CI/CD, BDD, performance testing, and multi-environment configs.

**Prerequisites:** Complete [robot-basics](https://github.com/RedBeret/robot-basics) and [robot-intermediate](https://github.com/RedBeret/robot-intermediate) first.

## What You'll Learn

| Suite | Topic | Key Concepts |
|-------|-------|-------------|
| 01_custom_framework | Framework Design | Base library, config loading, test decorators |
| 02_rest_api | REST API Framework | Session management, auth, response validation, chaining |
| 03_graphql | GraphQL Testing | Queries, mutations, variables, schema validation |
| 04_bdd_gherkin | BDD with Gherkin | Given/When/Then, feature files, scenario outlines |
| 05_docker | Docker Integration | Containerized test execution, service dependencies |
| 06_ci_cd | CI/CD Pipelines | GitHub Actions matrix, artifacts, parallel stages |
| 07_performance | Performance Testing | Load simulation, response time assertions, baselines |
| 08_multi_env | Multi-Environment | Config profiles, variable files, environment switching |
| 09_reporting | Custom Reporting | Report generation, metrics collection, dashboards |
| 10_real_world | Real-World Patterns | Retry, circuit breaker, test data management, cleanup |

## Requirements

- Python 3.10+
- Robot Framework 7.x
- Docker (for suite 05)
- Node.js 18+ (for Browser Library tests)

## Quick Start

```bash
# Clone
git clone https://github.com/RedBeret/robot-advanced.git
cd robot-advanced

# Create virtual environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
rfbrowser init

# Run all non-Docker tests
robot --outputdir results --exclude docker tests/

# Run a specific suite
robot --outputdir results tests/02_rest_api/

# Run with environment config
robot --outputdir results --variablefile config/dev/variables.py tests/

# Run with custom reporting
robot --outputdir results --listener libraries/MetricsCollector.py tests/
```

## Project Structure

```
robot-advanced/
├── tests/
│   ├── 01_custom_framework/    # Build your own test framework
│   ├── 02_rest_api/            # REST API testing patterns
│   ├── 03_graphql/             # GraphQL query testing
│   ├── 04_bdd_gherkin/         # BDD-style tests
│   ├── 05_docker/              # Containerized testing
│   ├── 06_ci_cd/               # CI/CD integration tests
│   ├── 07_performance/         # Performance and load testing
│   ├── 08_multi_env/           # Multi-environment configs
│   ├── 09_reporting/           # Custom report generation
│   └── 10_real_world/          # Production patterns
├── libraries/
│   ├── APIFramework.py         # REST API test framework
│   ├── GraphQLClient.py        # GraphQL client library
│   ├── ConfigManager.py        # Environment config loader
│   ├── MetricsCollector.py     # Custom metrics listener
│   └── RetryLibrary.py         # Retry and circuit breaker
├── resources/
│   ├── api_common.resource     # Shared API keywords
│   └── bdd_keywords.resource   # BDD step implementations
├── config/
│   ├── dev/variables.py        # Dev environment variables
│   ├── staging/variables.py    # Staging variables
│   └── prod/variables.py       # Production variables (read-only)
├── docker/
│   ├── Dockerfile              # Test execution container
│   └── docker-compose.yml      # Service dependencies
├── requirements.txt
└── README.md
```

## Tags

| Tag | Purpose |
|-----|---------|
| `advanced` | All advanced tests |
| `api` | API-related tests |
| `graphql` | GraphQL tests |
| `bdd` | BDD/Gherkin tests |
| `docker` | Requires Docker |
| `performance` | Performance tests (may be slow) |
| `smoke` | Quick validation subset |

## Docker Execution

```bash
# Build test container
docker build -t robot-advanced -f docker/Dockerfile .

# Run tests in container
docker run --rm -v $(pwd)/results:/results robot-advanced

# With docker-compose (includes mock API server)
docker compose -f docker/docker-compose.yml up --abort-on-container-exit
```

## CI/CD

The included GitHub Actions workflow runs:
1. Lint check (robocop)
2. Non-Docker tests in parallel
3. Artifact upload for reports
4. Multi-Python version matrix

## Next Steps

Ready for infrastructure testing? Continue with [robot-infra](https://github.com/RedBeret/robot-infra) — SSH, WinRM, network validation, firewall auditing, and full deployment pipelines across Linux and Windows targets.

## License

MIT
