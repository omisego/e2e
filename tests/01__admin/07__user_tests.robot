*** Settings ***
Documentation     Tests related to users
Suite Setup       Create Admin API Session
Suite Teardown    Delete All Sessions
Resource          admin_resources.robot

*** Variables ***
${JSON_PATH}      ${RESOURCE_PATH}/user

*** Test Cases ***
Create user successfully
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/create_user.json
    ${PROVIDER_USER_ID}    Generate Random String
    ${username}    Generate Random String
    &{override}    Create Dictionary    provider_user_id=${PROVIDER_USER_ID}    username=${username}
    ${data}    Update Json    ${data}    &{override}
    Set Global Variable    ${PROVIDER_USER_ID}
    ${json_data}    To Json    ${data}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_CREATE}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    user
    Should be Equal    ${resp.json()['data']['provider_user_id']}    ${json_data['provider_user_id']}
    Should be Equal    ${resp.json()['data']['username']}    ${json_data['username']}
    Dictionaries Should Be Equal    ${resp.json()['data']['metadata']}    ${json_data['metadata']}
    Dictionaries Should Be Equal    ${resp.json()['data']['encrypted_metadata']}    ${json_data['encrypted_metadata']}
    # Create an other user for later
    # Build payload
    ${PROVIDER_USER_1_ID}    Generate Random String
    ${username}    Generate Random String
    &{override}    Create Dictionary    provider_user_id=${PROVIDER_USER_1_ID}    username=${username}
    ${data}    Update Json    ${data}    &{override}
    Set Global Variable    ${PROVIDER_USER_1_ID}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_CREATE}    data=${data}    headers=${headers}
    Assert Response Success    ${resp}

Get user successfully
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/get_user.json
    ${data}    Update Json    ${data}    provider_user_id=${PROVIDER_USER_ID}
    ${json_data}    To Json    ${data}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_GET}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    user
    Should be Equal    ${resp.json()['data']['provider_user_id']}    ${PROVIDER_USER_ID}

Update user successfully
    # Initialize
    ${data}    Get Binary File    ${JSON_PATH}/update_user.json
    ${username}    Generate Random String
    &{override}    Create Dictionary    provider_user_id=${PROVIDER_USER_ID}    username=${username}
    ${data}    Update Json    ${data}    &{override}
    ${json_data}    To Json    ${data}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_UPDATE}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    user
    Should be Equal    ${resp.json()['data']['provider_user_id']}    ${json_data['provider_user_id']}
    Should be Equal    ${resp.json()['data']['username']}    ${json_data['username']}
    Dictionaries Should Be Equal    ${resp.json()['data']['metadata']}    ${json_data['metadata']}
    Should Be Empty    ${resp.json()['data']['encrypted_metadata']}

List all users successfully
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/get_users.json
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_ALL}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    list
    Should Not Be Empty    ${resp.json()['data']['data']}

List users from an account successfully
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/get_users_from_account.json
    ${data}    Update Json    ${data}    id=${MASTER_ACCOUNT_ID}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_ACCOUNT_GET_USERS}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    list
    Should Not Be Empty    ${resp.json()['data']['data']}

List user's wallets
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/get_wallets_for_user.json
    ${data}    Update Json    ${data}    provider_user_id=${PROVIDER_USER_ID}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_GET_WALLETS}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    list
    Should Not Be Empty    ${resp.json()['data']['data']}
    ${wallet}    Get From List    ${resp.json()['data']['data']}    0
    ${USER_PRIMARY_WALLET_ADDRESS}    Get Variable Value    ${wallet['address']}
    Set Global Variable    ${USER_PRIMARY_WALLET_ADDRESS}

List user's transactions
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/get_transactions_for_user.json
    ${data}    Update Json    ${data}    provider_user_id=${PROVIDER_USER_ID}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_GET_TRANSACTIONS}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    list

Disable a user successfully
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/enable_or_disable.json
    ${data}    Update Json    ${data}    provider_user_id=${PROVIDER_USER_ID}    enabled=${FALSE}
    ${json_data}    To Json    ${data}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_ENABLE_OR_DISABLE}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    user
    Should be Equal    ${resp.json()['data']['provider_user_id']}    ${PROVIDER_USER_ID}
    Should Not Be True    ${resp.json()['data']['enabled']}

Disable a user fails if id does not exist
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/enable_or_disable.json
    ${data}    Update Json    ${data}    provider_user_id=invalid_id    enabled=${FALSE}
    ${json_data}    To Json    ${data}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_ENABLE_OR_DISABLE}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Failure    ${resp}
    Assert Object Type    ${resp}    error
    Should be Equal    ${resp.json()['data']['code']}    unauthorized
    Should be Equal    ${resp.json()['data']['description']}    You are not allowed to perform the requested operation.

Login a user fails if the user is disabled
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/user_login.json
    ${data}    Update Json    ${data}    provider_user_id=${PROVIDER_USER_ID}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_LOGIN}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Failure    ${resp}
    Assert Object Type    ${resp}    error
    Should be Equal    ${resp.json()['data']['code']}    user:disabled
    Should be Equal    ${resp.json()['data']['description']}    This user is disabled.

Enable a user successfully
    # Build payload
    ${data}    Get Binary File    ${JSON_PATH}/enable_or_disable.json
    ${data}    Update Json    ${data}    provider_user_id=${PROVIDER_USER_ID}    enabled=${TRUE}
    ${json_data}    To Json    ${data}
    &{headers}    Build Authenticated Admin Request Header
    # Perform request
    ${resp}    Post Request    api    ${ADMIN_USER_ENABLE_OR_DISABLE}    data=${data}    headers=${headers}
    # Assert response
    Assert Response Success    ${resp}
    Assert Object Type    ${resp}    user
    Should be Equal    ${resp.json()['data']['provider_user_id']}    ${PROVIDER_USER_ID}
    Should Be True    ${resp.json()['data']['enabled']}
