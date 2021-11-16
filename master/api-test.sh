#!/bin/bash

# -----------------------------------------------------------------------------
# this script tests if salt-master-api is working properly
# -----------------------------------------------------------------------------

function usage() {
    echo "Usage: $0 [production|staging]"
    exit 1;
}

if [ $# -ne 1 ]; then
    usage;
fi

environment=$1

if [ "$environment" != "production" ] && [ "$environment" != "staging" ]; then
    usage;
fi

#
# get salt master api credentials
#

if [[ ! -f ~/.envio/credentials ]]; then
    echo "cannot find file ~/.envio/credentials"
    exit 1
fi

cred_permissions=`stat -c %a ~/.envio/credentials`
if [ $cred_permissions != "400" ]; then
    echo "file ~/.envio/credentials has not proper permissions, expected: 400, found: $cred_permissions"
    exit 1
fi

api_user=`cat ~/.envio/credentials | grep salt_master_api_user | cut -d "=" -f2`
api_pass=`cat ~/.envio/credentials | grep salt_master_api_pass | cut -d "=" -f2`

if [ -z "$api_user" ]; then
    echo "salt_master_api_user is not set in file ~/.envio/credentials"
    exit 1
fi

if [ -z "$api_pass" ]; then
    echo "salt_master_api_pass is not set in file ~/.envio/credentials"
    exit 1
fi

#
# api login
#

if [ "$environment" == "production" ]; then
    API_HOST="salt-master-internal.eng.envio.systems"
    elif [ "$environment" == "staging" ]; then
    API_HOST="salt-master-staging-internal.eng.envio.systems"
fi

payload=$( jq -n \
    --arg jq_arg1 "$api_user" \
    --arg jq_arg2 "$api_pass" \
'{username: $jq_arg1, password: $jq_arg2, eauth: "pam"}' )

cmd_response=`curl -ski https://${API_HOST}:7873/salt/api/login -H 'Content-type: application/json' -H 'Accept: application/json' -d "$payload" --connect-timeout 15`

cmd_response_status=`echo "${cmd_response}" | head -1 | sed 's/\r/\n/g'`

if [ "${cmd_response_status}" == "HTTP/1.1 200 OK" ]; then
    echo "test success! salt master api is accepting incoming connections"
    exit 0
else
    echo "salt master api command failed with response: ${cmd_response_status:-unable to execute}"
    exit 1
fi



