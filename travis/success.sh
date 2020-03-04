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
