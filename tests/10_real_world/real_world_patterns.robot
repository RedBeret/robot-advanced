*** Settings ***
Documentation    Real-world production patterns — retry, circuit breaker,
...              data cleanup, and resilient test execution
Library          ${CURDIR}/../../libraries/RetryLibrary.py
Library          ${CURDIR}/../../libraries/APIFramework.py
Library          Collections
Library          OperatingSystem
Default Tags     advanced    real-world

*** Variables ***
${TEMP_DATA_DIR}    ${TEMPDIR}${/}rf_real_world
${IDEMPOTENT_FILE}    ${TEMPDIR}${/}rf_real_world${/}idempotent.txt

*** Test Cases ***
Retry Keyword With Backoff
    [Documentation]    Retry a keyword that might fail transiently
    ${result}=    Retry Keyword    Flaky Keyword That Eventually Passes
    ...    retries=3    delay=0.5    backoff=1.5
    Should Be Equal    ${result}    success

Circuit Breaker Protects Against Cascading Failures
    [Documentation]    Circuit breaker opens after repeated failures
    Initialize Circuit Breaker    test-service    failure_threshold=2    reset_timeout=5
    Run Keyword And Expect Error    *    Execute With Circuit Breaker
    ...    test-service    Always Failing Keyword
    Run Keyword And Expect Error    *    Execute With Circuit Breaker
    ...    test-service    Always Failing Keyword
    ${state}=    Get Circuit Breaker State    test-service
    Should Be Equal    ${state}    open
    Run Keyword And Expect Error    *OPEN*    Execute With Circuit Breaker
    ...    test-service    Log    This should not execute

Test Data Setup And Cleanup Pattern
    [Documentation]    Create test data, use it, clean up regardless of outcome
    [Setup]    Create Test Data Directory
    Create File    ${TEMP_DATA_DIR}${/}user1.json    {"name": "Test User 1"}
    Create File    ${TEMP_DATA_DIR}${/}user2.json    {"name": "Test User 2"}
    ${files}=    List Files In Directory    ${TEMP_DATA_DIR}    *.json
    Length Should Be    ${files}    2
    [Teardown]    Cleanup Test Data Directory

API With Retry On Transient Failure
    [Documentation]    Real API call with retry wrapper
    [Tags]    advanced    real-world    network
    ${resp}=    Retry Keyword    GET    /posts/1
    ...    retries=2    delay=1.0    backoff=2.0
    Response Should Contain Key    title

Idempotent Test Pattern
    [Documentation]    Test that can run multiple times safely
    [Setup]    Run Keywords    Create Test Data Directory
    ...    AND    Remove File    ${IDEMPOTENT_FILE}
    Create File    ${IDEMPOTENT_FILE}    version1
    File Should Exist    ${IDEMPOTENT_FILE}
    ${content}=    Get File    ${IDEMPOTENT_FILE}
    Should Be Equal    ${content}    version1
    Create File    ${IDEMPOTENT_FILE}    version1
    ${content}=    Get File    ${IDEMPOTENT_FILE}
    Should Be Equal    ${content}    version1
    [Teardown]    Cleanup Test Data Directory

*** Keywords ***
Flaky Keyword That Eventually Passes
    [Documentation]    Simulates a flaky service — fails randomly then succeeds
    ${rand}=    Evaluate    __import__('random').random()
    IF    ${rand} < 0.3
        Fail    Transient failure (simulated)
    END
    RETURN    success

Always Failing Keyword
    Fail    Service unavailable (simulated)

Create Test Data Directory
    Create Directory    ${TEMP_DATA_DIR}

Cleanup Test Data Directory
    Remove Directory    ${TEMP_DATA_DIR}    recursive=True
