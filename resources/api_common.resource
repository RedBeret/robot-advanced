*** Settings ***
Library    ${CURDIR}/../libraries/APIFramework.py

*** Keywords ***
Setup API Session
    [Documentation]    Initialize API framework for test suite
    Set Base URL    https://jsonplaceholder.typicode.com

Verify Successful Response
    [Documentation]    Common assertion for API responses
    ${resp}=    Get Last Response
    Should Be True    ${resp}[status] >= 200 and ${resp}[status] < 300
    Response Time Should Be Below    5000
