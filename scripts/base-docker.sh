#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJ_DIR="$( realpath $DIR/.. )"

IMG_TAG=$(git log --format="%H" -n 1 | awk '{print substr($0,1,7)}')

echo "IMG_NAME=$IMG_NAME"
echo "IMG_REGISTRY=$IMG_REGISTRY"
echo "IMG_TAG=$IMG_TAG"
