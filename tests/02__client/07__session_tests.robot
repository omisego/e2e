*** Settings ***
Documentation    Tests related to sessions

Resource    client_resources.robot

Suite Setup     Create API Session
Suite Teardown  Delete All Sessions

*** Test Cases ***
Logout successfully
    # Build payload
    &{headers}    Build Authenticated Request Header

    # Perform request
    ${resp}    Post Request    api    ${CLIENT_LOGOUT}    headers=${headers}

    # Assert response
    Assert Response Success    ${resp}
