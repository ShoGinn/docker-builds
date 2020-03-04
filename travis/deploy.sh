#!/usr/bin/env bash

set -euo pipefail

# Setup
export DOCKER_CLI_EXPERIMENTAL="enabled"

DOCKERFILE="dockerfiles/${DOCKER_NAME}_${DOCKER_TAG}.dockerfile"
echo "Using ${DOCKERFILE}"

ARCHITECTURES=${ARCHITECTURES:-'linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6'}

# Deploy

docker buildx build --file ${DOCKERFILE} --platform ${ARCHITECTURES} -t ${DOCKER_USER}/${DOCKER_NAME}:${TRAVIS_COMMIT} -t ${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG} --push .
