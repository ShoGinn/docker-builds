#!/usr/bin/env bash

set -o errexit # Exit on most errors (see the manual)
#set -o errtrace # Make sure any error trap is inherited
set -o nounset  # Disallow expansion of unset variables
set -o pipefail # Use last non-zero exit code in a pipeline
set -o xtrace   # Trace the execution of the script (debug)

export DOCKER_CLI_EXPERIMENTAL="enabled"

DOCKERFILE="dockerfiles/${DOCKER_NAME}_${DOCKER_TAG}.dockerfile"
echo "Using ${DOCKERFILE}"

ARCHITECTURES=${ARCHITECTURES:-'linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6'}

# Adds a blank line to the end of the Dockerfile
[[ -n $(tail -c1 "${DOCKERFILE}") ]] && echo >>"${DOCKERFILE}"

# Append labels to dockerfile
cat <<-EOF >>"${DOCKERFILE}"
LABEL \
org.label-schema.build-date="${BUILD_DATE}" \
org.label-schema.build-number="${TRAVIS_BUILD_NUMBER}" \
org.label-schema.description="${DOCKER_DESCRIPTION}" \
org.label-schema.maintainer="${DOCKER_MAINTAINER}" \
org.label-schema.name="${DOCKER_NAME}" \
org.label-schema.url="${DOCKER_URL}" \
org.label-schema.schema-version="${SCHEMA_VERSION}" \
org.label-schema.vcs-ref="${VCS_REF}" \
org.label-schema.vcs-url="${VCS_URL}"
EOF
# Login into docker
echo "${DOCKER_PASS}" | sudo docker login --username "${DOCKER_USER}" --password-stdin

sudo docker run \
    --rm \
    --privileged \
    docker/binfmt:66f9012c56a8316f9244ffd7622d7c21c1f6f28d

sudo docker buildx create --name multi
sudo docker buildx use multi
sudo docker buildx inspect --bootstrap

sudo docker buildx build \
    --file "${DOCKERFILE}" \
    --platform "${ARCHITECTURES}" \
    -t "${DOCKER_USER}/${DOCKER_NAME}:${TRAVIS_COMMIT}" \
    -t "${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG}" .
