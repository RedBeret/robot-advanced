*** Settings ***
Documentation    REST API testing with custom framework — session management,
...              response chaining, validation, and performance assertions
Library          ${CURDIR}/../../libraries/APIFramework.py
Default Tags     advanced    api

*** Test Cases ***
GET A Single Resource
    [Documentation]    Fetch a resource and validate structure
    ${resp}=    GET    /posts/1
    Response Should Contain Key    userId
    Response Should Contain Key    title
    Response Should Contain Key    body
    Response Value Should Be    id    1

GET A List Of Resources
    [Documentation]    Fetch collection and validate count
    ${resp}=    GET    /posts
    ${count}=    Evaluate    len($resp['body'])
    Should Be True    ${count} > 0

POST Creates A New Resource
    [Documentation]    Create a resource and validate response
    ${body}=    Evaluate    {"title": "Test Post", "body": "Test content", "userId": 1}
    ${resp}=    POST    /posts    ${body}
    Response Value Should Be    title    Test Post
    Response Value Should Be    userId    1

PUT Updates A Resource
    [Documentation]    Full update of an existing resource
    ${body}=    Evaluate    {"id": 1, "title": "Updated", "body": "New content", "userId": 1}
    ${resp}=    PUT    /posts/1    ${body}
    Response Value Should Be    title    Updated

DELETE Removes A Resource
    [Documentation]    Delete a resource
    DELETE    /posts/1

Response Chaining Between Requests
    [Documentation]    Use a value from one response in the next request
    GET    /users/1
    Save Response Value    user_email    email
    ${email}=    Get Saved Value    user_email
    Should Not Be Empty    ${email}
    GET    /users/1
    Response Value Should Be    email    ${email}

Response Time Assertion
    [Documentation]    Verify API responds within acceptable time
    [Tags]    advanced    api    performance
    GET    /posts/1
    Response Time Should Be Below    5000

Nested JSON Navigation
    [Documentation]    Navigate deep into response structures
    GET    /users/1
    Response Should Contain Key    address
    Response Value Should Be    name    Leanne Graham

Handle 404 Not Found
    [Documentation]    Validate error responses
    GET    /posts/99999    expected_status=404
    ${resp}=    Get Last Response
    Should Be Equal As Integers    ${resp}[status]    404
