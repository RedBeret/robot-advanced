*** Settings ***
Documentation    Tests designed for CI/CD pipelines — fast, deterministic,
...              no external dependencies. Use these as your CI smoke suite.
Library          BuiltIn
Library          String
Library          Collections
Library          OperatingSystem
Default Tags     advanced    ci    smoke

*** Test Cases ***
Smoke Test - Application Math
    [Documentation]    Quick validation test for CI pipelines
    ${result}=    Evaluate    100 * 0.15
    Should Be Equal As Numbers    ${result}    15.0

Smoke Test - String Processing
    ${input}=    Set Variable    Hello, Robot Framework!
    ${upper}=    Convert To Upper Case    ${input}
    Should Be Equal    ${upper}    HELLO, ROBOT FRAMEWORK!
    ${length}=    Get Length    ${input}
    Should Be Equal As Integers    ${length}    23

Smoke Test - Data Structures
    ${users}=    Create List    alice    bob    carol
    ${config}=    Create Dictionary    timeout=${30}    retries=${3}
    Length Should Be    ${users}    3
    Dictionary Should Contain Key    ${config}    timeout

Smoke Test - File System
    ${temp}=    Set Variable    ${TEMPDIR}${/}ci_smoke_test.txt
    Create File    ${temp}    CI smoke test content
    File Should Exist    ${temp}
    ${content}=    Get File    ${temp}
    Should Contain    ${content}    CI smoke test
    [Teardown]    Remove File    ${temp}

Smoke Test - Environment
    ${home}=    Get Environment Variable    HOME    /tmp
    Should Not Be Empty    ${home}
    ${path}=    Get Environment Variable    PATH
    Should Not Be Empty    ${path}

Regression - Edge Case Empty String
    [Tags]    advanced    ci    regression
    ${empty}=    Set Variable    ${EMPTY}
    Should Be Empty    ${empty}
    ${length}=    Get Length    ${empty}
    Should Be Equal As Integers    ${length}    0

Regression - Edge Case Large List
    [Tags]    advanced    ci    regression
    ${large}=    Evaluate    list(range(1000))
    Length Should Be    ${large}    1000
    Should Be Equal As Integers    ${large}[0]    0
    Should Be Equal As Integers    ${large}[999]    999
