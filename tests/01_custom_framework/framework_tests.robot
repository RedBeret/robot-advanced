*** Settings ***
Documentation    Build a custom test framework — structured base keywords,
...              config loading, and reusable patterns
Library          ${CURDIR}/../../libraries/ConfigManager.py
Library          Collections
Default Tags     advanced    framework

*** Test Cases ***
Config Manager Loads Dev Environment
    [Documentation]    ConfigManager reads environment-specific settings
    ${env}=    Get Current Environment
    Should Be Equal    ${env}    dev

Switch Between Environments
    [Documentation]    Dynamically change environment at runtime
    Switch Environment    staging
    ${env}=    Get Current Environment
    Should Be Equal    ${env}    staging
    [Teardown]    Switch Environment    dev

Read Config Values With Dot Notation
    [Documentation]    Access nested config values
    ${base_url}=    Get Config Value    api.base_url    http://localhost:8080
    Should Not Be Empty    ${base_url}

Missing Config Returns Default
    [Documentation]    Graceful handling of missing keys
    ${value}=    Get Config Value    nonexistent.key    fallback_value
    Should Be Equal    ${value}    fallback_value

Config Assertion Keyword
    [Documentation]    Assert required config keys exist
    Run Keyword And Expect Error    *missing key*
    ...    Config Should Have Key    nonexistent.key
