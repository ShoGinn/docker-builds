#!/usr/bin/env bash

set -o errexit # Exit on most errors (see the manual)
#set -o errtrace # Make sure any error trap is inherited
set -o nounset  # Disallow expansion of unset variables
set -o pipefail # Use last non-zero exit code in a pipeline
set -o xtrace   # Trace the execution of the script (debug)

# Setup

export DOCKER_CLI_EXPERIMENTAL="enabled"

DOCKERFILE="dockerfiles/${DOCKER_NAME}_${DOCKER_TAG}.dockerfile"
echo "Using ${DOCKERFILE}"

ARCHITECTURES=${ARCHITECTURES:-'linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6'}

# Deploy

sudo docker buildx build --file "${DOCKERFILE}" --platform "${ARCHITECTURES}" -t "${DOCKER_USER}/${DOCKER_NAME}:${TRAVIS_COMMIT}" -t "${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG}" --push .
