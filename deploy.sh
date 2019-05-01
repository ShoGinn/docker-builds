#!/usr/bin/env bash

set -euo pipefail

# Enable docker experimental client
export DOCKER_CLI_EXPERIMENTAL="enabled"

# Architectures to build
ARCHITECTURES="arm arm64 amd64"

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