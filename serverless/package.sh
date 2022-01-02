#!/usr/bin/env bash

set -e

rm -rf deploy
mkdir deploy

# packaging layer
mkdir -p deploy
rm -rf tmp/base
mkdir -p tmp/base/nodejs
cp package.json tmp/base/nodejs
pushd tmp/base/nodejs 2>&1>/dev/null
  docker run --platform linux/amd64 -v "$PWD":/var/task lambci/lambda:build-nodejs12.x npm install --no-optional --only=prod
popd 2>&1>/dev/null
pushd tmp/base 2>&1>/dev/null
    rm nodejs/package.json
    zip -r ../../deploy/layer-base.zip . 2>&1>/dev/null
popd 2>&1>/dev/null
if [[ ! -f deploy/layer-base.zip ]];then
    echo "Packaging failed! Distribution package ZIP file could not be found."
    exit 1
fi
