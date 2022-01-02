#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" ; pwd -P)

AWS_REGION=eu-central-1
SOCIAL_BUCKET=$(cat "configuration.json" | jq -r '.terraform_dist_bucket')
BACKEND_BUCKET=$(cat "configuration.json" | jq -r '.terraform_backend_bucket')
BACKEND_LOCK_TABLE=$(cat "configuration.json" | jq -r '.terraform_lock_table')

function goal_apply-tf() {
    pushd "${SCRIPT_DIR}/infra/account" >/dev/null
        set +e
          cp main.tf main.backup
          sed -i '' "s/\$BACKEND_BUCKET/$BACKEND_BUCKET/" "main.tf"
          sed -i '' "s/\$BACKEND_LOCK_TABLE/$BACKEND_LOCK_TABLE/" "main.tf"
          terraform init -upgrade
          terraform apply
          mv main.backup main.tf
        set -e
    popd >/dev/null
}

function goal_deploy-sls() {
    pushd "${SCRIPT_DIR}/serverless" >/dev/null
        sls deploy
    popd >/dev/null
}

function goal_package-layer() {
    pushd "${SCRIPT_DIR}/serverless" >/dev/null
        ./package.sh
    popd >/dev/null
}

function goal_start() {
  pushd app > /dev/null 2>&1
      yarn start
  popd
}

function goal_rollout() {
    if [[ "${@#--skip-packaging}" = "$@" ]];then
      goal_build
    fi
    goal_deploy-app
}

function goal_build() {
    pushd app > /dev/null 2>&1
        export NODE_ENV=production
        if [[ ${account} == preview ]];then
          echo "Building for Preview..."
          yarn run build
        else
          echo "Building for Production..."
          yarn run build --configuration production
        fi
    popd > /dev/null 2>&1
}

function goal_deploy-app() {
    pushd app > /dev/null 2>&1
        echo -e "Uploading to bucket ${SOCIAL_BUCKET}..."
        aws s3 sync dist/social s3://${SOCIAL_BUCKET}${WEB_UI_BASE_HREF} --sse --delete --cache-control no-cache --exact-timestamps --exclude "index.html" --region eu-central-1 2>&1
        aws s3 cp dist/social/index.html s3://${SOCIAL_BUCKET} --sse --cache-control "max-age=0" --region eu-central-1 2>&1
        echo -e "Upload to bucket ${SOCIAL_BUCKET} completed"
    popd > /dev/null 2>&1
}

if type -t "goal_$1" &>/dev/null; then
  goal_"$1" "${@:2}"
else
  echo -e "Usage: $0 <goal>

    apply-tf        - apply terraform
    deploy-sls      - deploy serverless
    package-layer   - package layer
    start           - start local server
    rollout         - build & deploy angular app
    build           - build angular app
    deploy-app      - deploy angular app
  "
  exit 1
fi
