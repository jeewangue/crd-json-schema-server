#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJ_DIR="$(realpath $DIR/..)"
source $PROJ_DIR/scripts/base-docker.sh

docker build \
  -f Dockerfile \
  -t ${IMG_NAME}:${IMG_TAG} $PROJ_DIR

docker tag ${IMG_NAME}:${IMG_TAG} ${IMG_REGISTRY}/${IMG_NAME}:${IMG_TAG}
