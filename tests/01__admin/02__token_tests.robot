*** Settings ***
Documentation    Tests related to tokens

Resource    admin_resources.robot

Suite Setup     Create API Session
Suite Teardown  Delete All Sessions

*** Test Cases ***
Create a token successfully
    # Build payload
    ${data}         Get Binary File    ${RESOURCE}/create_token.json
    ${json_data}    To Json            ${data}
    &{headers}      Build Authenticated Admin Request Header

    # Perform request
    ${resp}        Post Request    api    ${ADMIN_TOKEN_CREATE}    data=${data}    headers=${headers}

    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type         ${resp}    token
    Should be Equal            ${resp.json()['data']['symbol']}             ${json_data['symbol']}
    Should be Equal            ${resp.json()['data']['name']}               ${json_data['name']}
    Should be Equal            ${resp.json()['data']['subunit_to_unit']}    ${json_data['subunit_to_unit']}
    Should be Equal            ${resp.json()['data']['symbol']}             ${json_data['symbol']}

    ${TOKEN_ID}     Get Variable Value    ${resp.json()['data']['id']}
    Set Global Variable    ${TOKEN_ID}

Mint a token successfully
    # Build payload
    ${data}         Get Binary File    ${RESOURCE}/mint_token.json
    ${data}         Update Json        ${data}            id=${TOKEN_ID}
    &{headers}      Build Authenticated Admin Request Header

    # Perform request
    ${resp}        Post Request    api    ${ADMIN_TOKEN_MINT}    data=${data}    headers=${headers}

    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type         ${resp}    token
    Should be Equal            ${resp.json()['data']['id']}                 ${TOKEN_ID}

Get a token successfully
    # Build payload
    ${data}         Get Binary File    ${RESOURCE}/get_token.json
    ${data}         Update Json        ${data}            id=${TOKEN_ID}
    &{headers}           Build Authenticated Admin Request Header

    # Perform request
    ${resp}        Post Request    api    ${ADMIN_TOKEN_GET}    data=${data}    headers=${headers}

    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type         ${resp}    token
    Should be Equal            ${resp.json()['data']['id']}                 ${TOKEN_ID}

Get all tokens successfully
    # Build payload
    ${data}         Get Binary File    ${RESOURCE}/list_tokens.json
    ${json_data}    To Json            ${data}

    &{headers}           Build Authenticated Admin Request Header

    # Perform request
    ${resp}        Post Request    api    ${ADMIN_TOKEN_LIST}    data=${data}    headers=${headers}

    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type         ${resp}    list
    Should Not Be Empty        ${resp.json()['data']['data']}