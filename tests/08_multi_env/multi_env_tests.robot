*** Settings ***
Documentation    Multi-environment configuration — load different configs
...              per environment using variable files and ConfigManager
...              Run with: robot --variablefile config/dev/variables.py tests/08_multi_env/
Library          ${CURDIR}/../../libraries/ConfigManager.py
Library          BuiltIn
Default Tags     advanced    multi-env

*** Test Cases ***
Environment Name Is Loaded
    [Documentation]    Verify we're running in the expected environment
    ${env}=    Get Current Environment
    Log    Running in environment: ${env}

Variable File Values Are Accessible
    [Documentation]    Variables from --variablefile are available
    ${env}=    Get Variable Value    ${ENV_NAME}    unknown
    Log    ENV_NAME from variable file: ${env}

Config YAML Is Loaded For Environment
    [Documentation]    ConfigManager reads the right config.yaml
    ${url}=    Get Config Value    api.base_url
    Should Not Be Empty    ${url}
    Log    API base URL: ${url}

Config Timeout Has Sensible Value
    ${timeout}=    Get Config Value    api.timeout    30
    Should Be True    ${timeout} > 0

Switch Environment At Runtime
    [Documentation]    Dynamically switch config mid-test
    ${dev_url}=    Get Config Value    api.base_url
    Switch Environment    staging
    ${staging_url}=    Get Config Value    api.base_url
    Log    Dev: ${dev_url} | Staging: ${staging_url}
    [Teardown]    Switch Environment    dev
