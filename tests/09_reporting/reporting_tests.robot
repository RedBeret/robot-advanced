*** Settings ***
Documentation    Custom reporting — run with the MetricsCollector listener
...              robot --listener libraries/MetricsCollector.py --outputdir results tests/09_reporting/
Library          BuiltIn
Library          String
Library          Collections
Default Tags     advanced    reporting

*** Test Cases ***
Fast Test For Metrics
    [Documentation]    Quick test to appear in the metrics report
    [Tags]    advanced    reporting    smoke
    ${result}=    Evaluate    1 + 1
    Should Be Equal As Integers    ${result}    2

Medium Duration Test
    [Documentation]    Slightly slower test to show timing variance
    [Tags]    advanced    reporting
    Sleep    0.3s
    ${list}=    Create List    a    b    c    d    e
    Length Should Be    ${list}    5

String Processing Test
    [Documentation]    String operations for the report
    [Tags]    advanced    reporting
    ${upper}=    Convert To Upper Case    robot framework
    Should Be Equal    ${upper}    ROBOT FRAMEWORK
    ${words}=    Split String    Robot Framework Testing    ${SPACE}
    Length Should Be    ${words}    3

Collection Operations Test
    [Documentation]    Collection operations for timing metrics
    [Tags]    advanced    reporting
    ${dict}=    Create Dictionary    name=Test    value=${42}    active=${TRUE}
    Dictionary Should Contain Key    ${dict}    name
    Dictionary Should Contain Value    ${dict}    ${42}
    ${keys}=    Get Dictionary Keys    ${dict}
    Length Should Be    ${keys}    3

Math Intensive Test
    [Documentation]    Computation-heavy test for the performance chart
    [Tags]    advanced    reporting    slow
    ${primes}=    Evaluate
    ...    [n for n in range(2, 1000) if all(n % i != 0 for i in range(2, int(n**0.5)+1))]
    ${count}=    Get Length    ${primes}
    Should Be Equal As Integers    ${count}    168
