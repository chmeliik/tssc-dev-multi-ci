#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )" 

# buildah-rhtap
source $SCRIPTDIR/common.sh

# Top level parameters 
export IMAGE=quay.io/jduimovich0/bootstrap
export DOCKERFILE=Dockerfile
export CONTEXT=.
export TLSVERIFY=false
export BUILD_ARGS=""
export BUILD_ARGS_FILE=""


function build() {
	echo "Running $TASK_NAME:build"
	# Check if the Dockerfile exists
	SOURCE_CODE_DIR=.
	if [ -e "$SOURCE_CODE_DIR/$CONTEXT/$DOCKERFILE" ]; then
	  dockerfile_path="$SOURCE_CODE_DIR/$CONTEXT/$DOCKERFILE"
	elif [ -e "$SOURCE_CODE_DIR/$DOCKERFILE" ]; then
	  dockerfile_path="$SOURCE_CODE_DIR/$DOCKERFILE"
	else
	  echo "Cannot find Dockerfile $DOCKERFILE"
	  exit 1
	fi
	
	BUILDAH_ARGS=()
	if [ -n "${BUILD_ARGS_FILE}" ]; then
	  BUILDAH_ARGS+=("--build-arg-file=${SOURCE_CODE_DIR}/${BUILD_ARGS_FILE}")
	fi
	
	for build_arg in "$@"; do
	  BUILDAH_ARGS+=("--build-arg=$build_arg")
	done
	
	# Build the image
	buildah build \
	  "${BUILDAH_ARGS[@]}" \
	  --tls-verify=$TLSVERIFY \
	  --ulimit nofile=4096:4096 \
	  -f "$dockerfile_path" -t $IMAGE $SOURCE_CODE_DIR/$CONTEXT
	
	# Push the image
	buildah push \
	  --tls-verify=$TLSVERIFY \
	  --retry=5 \
	  --digestfile /tmp/files/image-digest $IMAGE \
	  docker://$IMAGE
	
	# Set task results
	buildah images --format '{{ .Name }}:{{ .Tag }}@{{ .Digest }}' | grep -v $IMAGE > $RESULTS/BASE_IMAGES_DIGESTS
	cat /tmp/files/image-digest | tee $RESULTS/IMAGE_DIGEST
	echo -n "$IMAGE" | tee $RESULTS/IMAGE_URL
	
	# Save the image so it can be used in the generate-sbom step
	buildah push "$IMAGE" oci:/tmp/files/image
	
}

function generate-sboms() {
	echo "Running $TASK_NAME:generate-sboms"
	syft dir:$(workspaces.source.path)/source --output cyclonedx-json@1.5=/tmp/files/sbom-source.json
	syft oci-dir:/tmp/files/image --output cyclonedx-json@1.5=/tmp/files/sbom-image.json
	
}

function upload-sbom() {
	echo "Running $TASK_NAME:upload-sbom"
	cosign
}

# Task Steps 
build
generate-sboms
$SCRIPTDIR/merge-sboms.sh
upload-sbom