#!/usr/bin/env bash

set -euo pipefail

# Enable docker experimental client
export DOCKER_CLI_EXPERIMENTAL="enabled"

# Architectures to build
ARCHITECTURES=${ARCHITECTURES:-'arm arm64 amd64'}

for ARCH in $ARCHITECTURES; do

	# Images to add to docker manifest list
	DOCKER_IMAGES+="${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG}-${ARCH} "

done

# Create docker manifest list
docker manifest create ${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG} ${DOCKER_IMAGES}

for ARCH in $ARCHITECTURES; do

	# Annotate docker manifest list
	docker manifest annotate --arch ${ARCH} --os linux \
	${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG} \
	${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG}-${ARCH}

done

# Login into docker
echo ${DOCKER_PASS} | docker login --username ${DOCKER_USER} --password-stdin

# Push docker manifest list
docker manifest push ${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG}

# Display docker manifest list
docker manifest inspect ${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG}

# Push the Readme File
local README_NAME="README.md"
local token=$(curl -s -X POST \
-H "Content-Type: application/json" \
-d '{"username": "'"${DOCKER_USER}"'", "password": "'"${DOCKER_PASS}"'"}' \
https://hub.docker.com/v2/users/login/ | jq -r .token)

local code=$(jq -n --arg msg "$(<${README_NAME})" \
'{"registry":"registry-1.docker.io","full_description": $msg }' | \
    curl -s -o /dev/null  -L -w "%{http_code}" \
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