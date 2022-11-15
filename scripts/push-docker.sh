#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJ_DIR="$(realpath $DIR/..)"
source $PROJ_DIR/scripts/base-docker.sh

docker push ${IMG_REGISTRY}/${IMG_NAME}:${IMG_TAG}
