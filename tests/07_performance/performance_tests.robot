*** Settings ***
Documentation    Performance testing — response time assertions,
...              load simulation, and baseline comparisons
Library          ${CURDIR}/../../libraries/APIFramework.py
Library          Collections
Library          DateTime
Default Tags     advanced    performance

*** Variables ***
${MAX_RESPONSE_TIME}    3000
${ITERATIONS}           5

*** Test Cases ***
Single Request Response Time
    [Documentation]    Verify a single API call meets the SLA
    GET    /posts/1
    Response Time Should Be Below    ${MAX_RESPONSE_TIME}

Repeated Requests Measure Consistency
    [Documentation]    Run multiple requests and check all are within SLA
    [Tags]    advanced    performance    slow
    @{times}=    Create List
    FOR    ${i}    IN RANGE    ${ITERATIONS}
        ${resp}=    GET    /posts/1
        ${duration}=    Set Variable    ${resp}[duration_ms]
        Append To List    ${times}    ${duration}
        Response Time Should Be Below    ${MAX_RESPONSE_TIME}
    END
    Log    Response times: ${times}
    ${avg}=    Evaluate    sum($times) / len($times)
    Log    Average response time: ${avg}ms
    Should Be True    ${avg} < ${MAX_RESPONSE_TIME}
    ...    Average response time ${avg}ms exceeds ${MAX_RESPONSE_TIME}ms

Response Size Should Be Reasonable
    [Documentation]    Check payload isn't unexpectedly large
    ${resp}=    GET    /posts/1
    ${body_str}=    Evaluate    __import__('json').dumps($resp['body'])
    ${size}=    Get Length    ${body_str}
    Should Be True    ${size} < 10000
    ...    Response body is ${size} chars — suspiciously large

Concurrent-Style Sequential Load Test
    [Documentation]    Simulate multiple sequential requests (load pattern)
    [Tags]    advanced    performance    slow
    @{results}=    Create List
    FOR    ${i}    IN RANGE    10
        ${resp}=    GET    /posts/${i + 1}
        Append To List    ${results}    ${resp}[status]
    END
    FOR    ${status}    IN    @{results}
        Should Be Equal As Integers    ${status}    200
    END

Compare Endpoints Performance
    [Documentation]    Compare response times between endpoints
    ${resp1}=    GET    /posts/1
    ${time1}=    Set Variable    ${resp1}[duration_ms]
    ${resp2}=    GET    /users/1
    ${time2}=    Set Variable    ${resp2}[duration_ms]
    Log    /posts/1: ${time1}ms vs /users/1: ${time2}ms
