*** Settings ***
Documentation    Tests designed to run inside Docker containers
...              Demonstrates containerized test execution patterns
...              Run with: docker compose -f docker/docker-compose.yml up
Library          Process
Library          OperatingSystem
Default Tags     advanced    docker

*** Test Cases ***
Verify Python Environment In Container
    [Documentation]    Ensure the container has the right Python setup
    ${result}=    Run Process    python3    --version
    Should Contain    ${result.stdout}    Python 3

Verify Robot Framework Is Installed
    [Documentation]    Check RF is available
    ${result}=    Run Process    robot    --version
    Should Be Equal As Integers    ${result.rc}    0

Verify Working Directory
    [Documentation]    Confirm we're in the expected directory
    ${cwd}=    Evaluate    __import__('os').getcwd()
    Log    Current directory: ${cwd}

Environment Variables Are Accessible
    [Documentation]    Container env vars are available to tests
    ${env}=    Get Environment Variable    RF_ENV    not_set
    Log    RF_ENV = ${env}

File System Is Writable
    [Documentation]    Verify we can write to results directory
    Create File    /tmp/docker_test_file.txt    Docker test write
    File Should Exist    /tmp/docker_test_file.txt
    [Teardown]    Remove File    /tmp/docker_test_file.txt
