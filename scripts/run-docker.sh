#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
PROJ_DIR="$(realpath $DIR/..)"
source $PROJ_DIR/scripts/base-docker.sh

docker run -v ${PROJ_DIR}/test/kubeconfig:/kube/config -e KUBECONFIG=/kube/config --add-host=host.docker.internal:host-gateway -p 9292:9292 ${IMG_REGISTRY}/${IMG_NAME}:${IMG_TAG}
