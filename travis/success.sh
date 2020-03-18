#!/usr/bin/env bash

set -o errexit # Exit on most errors (see the manual)
#set -o errtrace # Make sure any error trap is inherited
set -o nounset  # Disallow expansion of unset variables
set -o pipefail # Use last non-zero exit code in a pipeline
set -o xtrace   # Trace the execution of the script (debug)

# Push the Readme File
README_NAME="README.md"

token=$(curl -s -X POST \
    -H "Content-Type: application/json" \
    -d '{"username": "'"${DOCKER_USER}"'", "password": "'"${DOCKER_PASS}"'"}' \
    https://hub.docker.com/v2/users/login/ | jq -r .token)

code=$(jq -n --arg msg "$(<${README_NAME})" \
    '{"registry":"registry-1.docker.io","full_description": $msg }' |
    curl -s -o /dev/null -L -w "%{http_code}" \
        https://hub.docker.com/v2/repositories/"${DOCKER_USER}"/"${DOCKER_NAME}"/ \
        -d @- -X PATCH \
        -H "Content-Type: application/json" \
        -H "Authorization: JWT ${token}")

if [[ "${code}" = "200" ]]; then
    printf "Successfully pushed %s to Docker Hub\n" "${README_NAME}"
else
    printf "Unable to push %s to Docker Hub, the response code: %s\n" "${README_NAME}" "${code}"
    exit 1
fi
