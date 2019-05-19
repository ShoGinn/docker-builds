#!/usr/bin/env bash

set -u

# Architectures to build
ARCHITECTURES=${ARCHITECTURES:-'arm arm64 amd64'}

for ARCH in $ARCHITECTURES; do

	# Set dockerfile directory/filename
	DOCKERFILE="dockerfiles/${DOCKER_NAME}_${DOCKER_TAG}_${ARCH}.dockerfile"
	[[ ! -f ${DOCKERFILE} ]] && DOCKERFILE="dockerfiles/${DOCKER_NAME}_${DOCKER_TAG}.dockerfile" 
	echo "Using ${DOCKERFILE}"
	
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
	cat ${DOCKERFILE}
	# Login into docker
	echo ${DOCKER_PASS} | docker login --username ${DOCKER_USER} --password-stdin

	# Build docker image
	buildctl build \
		--frontend dockerfile.v0 \
		--progress plain \
		--opt platform=linux/${ARCH} \
		--opt filename=${DOCKERFILE} \
		--local dockerfile=. \
		--local context=. \
		--output type=image,name=docker.io/${DOCKER_USER}/${DOCKER_NAME}:${DOCKER_TAG}-${ARCH},push=true

done
