*** Settings ***
Documentation    GraphQL query and mutation testing
...              Uses the public Countries GraphQL API
Library          ${CURDIR}/../../libraries/GraphQLClient.py
Library          Collections
Default Tags     advanced    graphql

*** Test Cases ***
Simple Query Returns Data
    [Documentation]    Basic GraphQL query execution
    ${data}=    Execute GraphQL Query
    ...    { countries { code name } }
    GraphQL Response Should Not Have Errors
    Should Not Be Empty    ${data}

Query With Filter
    [Documentation]    Query with arguments/filter
    ${data}=    Execute GraphQL Query
    ...    { country(code: "US") { name capital currency } }
    GraphQL Response Should Not Have Errors
    ${name}=    Get GraphQL Field    country    name
    Should Be Equal    ${name}    United States

Query With Variables
    [Documentation]    Use GraphQL variables for parameterized queries
    ${variables}=    Evaluate    {"code": "GB"}
    ${data}=    Execute GraphQL Query
    ...    query GetCountry($code: ID!) { country(code: $code) { name capital } }
    ...    ${variables}
    GraphQL Response Should Not Have Errors
    ${name}=    Get GraphQL Field    country    name
    Should Be Equal    ${name}    United Kingdom

Query Nested Objects
    [Documentation]    Navigate nested GraphQL response structures
    ${data}=    Execute GraphQL Query
    ...    { country(code: "FR") { name languages { name } continent { name } } }
    GraphQL Response Should Not Have Errors
    ${continent}=    Get GraphQL Field    country    continent    name
    Should Be Equal    ${continent}    Europe

Query Returns List
    [Documentation]    Query that returns an array
    ${data}=    Execute GraphQL Query
    ...    { continent(code: "EU") { name countries { name } } }
    GraphQL Response Should Not Have Errors
    ${continent_name}=    Get GraphQL Field    continent    name
    Should Be Equal    ${continent_name}    Europe

Error Response For Invalid Query
    [Documentation]    Verify GraphQL returns errors for bad queries
    ${data}=    Execute GraphQL Query
    ...    { invalid_field_that_does_not_exist }
    Run Keyword And Expect Error    *errors*
    ...    GraphQL Response Should Not Have Errors
