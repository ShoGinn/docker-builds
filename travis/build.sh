#!/usr/bin/env bash

set -u

export DOCKER_CLI_EXPERIMENTAL="enabled"

DOCKERFILE="dockerfiles/${DOCKER_NAME}_${DOCKER_TAG}.dockerfile" 
echo "Using ${DOCKERFILE}"

ARCHITECTURES=${ARCHITECTURES:-'linux/amd64,linux/arm64,linux/arm/v7,linux/arm/v6'}
# Adds a blank line to the end of the Dockerfile
[ -n "$(tail -c1 ${DOCKERFILE})" ] && echo >> ${DOCKERFILE}

# Append labels to dockerfile
cat <<- EOF >> ${DOCKERFILE}
LABEL \
org.label-schema.build-date="${BUILD_DATE}" \
org.label-schema.build-number="${BUILD_NUMBER}" \
org.label-schema.description="${DOCKER_DESCRIPTION}" \
org.label-schema.maintainer="${DOCKER_MAINTAINER}" \
org.label-schema.name="${DOCKER_NAME}" \
org.label-schema.url="${DOCKER_URL}" \
org.label-schema.schema-version="${SCHEMA_VERSION}" \
org.label-schema.vcs-ref="${VCS_REF}" \
org.label-schema.vcs-url="${VCS_URL}"
EOF
# Login into docker
echo ${DOCKER_PASS} | docker login --username ${DOCKER_USER} --password-stdin


docker run --rm --privileged docker/binfmg:66f9012c56a8316f9244ffd7622d7c21c1f6f28d
docker buildx create --name multi
docker buildx use multi
docker buildx inspect --bootstrap
docker buildx build --file {DOCKERFILE} --platform ${ARCHITECTURES} -t ${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG} --push .
docker buildx build --file {DOCKERFILE} --platform ${ARCHITECTURES} -t ${DOCKER_USER}/${DOCKER_NAME}:${TRAVIS_COMMIT} --push .
