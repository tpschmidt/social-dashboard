#!/usr/bin/env bash

set -e

SCRIPT_DIR=$(cd "$(dirname "$0")" ; pwd -P)
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
NC='\033[0m'

AWS_REGION=eu-central-1
DIST_BUCKET=$(cat "${SCRIPT_DIR}/configuration.json" | jq -r '.terraform_dist_bucket')
TERRAFORM_STATE_BUCKET=$(cat "${SCRIPT_DIR}/configuration.json" | jq -r '.terraform_state_bucket')
TERRAFORM_LOCK_TABLE=$(cat "${SCRIPT_DIR}/configuration.json" | jq -r '.terraform_lock_table')

function goal_go() {
    goal_bootstrap-tf
    goal_apply-tf
    goal_rollout
}

function goal_bootstrap-tf() {
    set +e

    BUCKET_EXISTS=$(aws s3api head-bucket --bucket $TERRAFORM_STATE_BUCKET 2>&1)
    if [[ $? == 0 ]];then
        echo -e "Bucket ${ORANGE}${TERRAFORM_STATE_BUCKET}${NC} already exists & is owned by you ✅"
    elif [[ $(echo $BUCKET_EXISTS | grep '404') ]];then
        echo -e "Bucket ${ORANGE}${TERRAFORM_STATE_BUCKET}${NC} does not exist yet! Creating..."
        aws s3api create-bucket --bucket $TERRAFORM_STATE_BUCKET --region $AWS_REGION
        echo -e "Bucket ${ORANGE}${TERRAFORM_STATE_BUCKET}${NC} created successfully 🎉"
    else
        echo -e "${RED}ERROR${NC}> Bucket name already taken!"
    fi

    # check if DynamoDB table already exists
    TABLE_EXISTS=$(aws dynamodb list-tables --region $AWS_REGION | grep $TERRAFORM_LOCK_TABLE 2>&1)

    if [[ $? == 0 ]];then
        echo -e "Table ${ORANGE}${TERRAFORM_LOCK_TABLE}${NC} already exists ✅"
    elif [[ $(echo $BUCKET_EXISTS | grep '404') ]];then
        echo -e "Table ${ORANGE}${TERRAFORM_LOCK_TABLE}${NC} does not exist yet! Creating..."
        # create DynamoDB table with provisioned capacity
        aws dynamodb create-table --table-name $TERRAFORM_LOCK_TABLE \
            --attribute-definitions AttributeName=LockID,AttributeType=S \
                --key-schema AttributeName=LockID,KeyType=HASH \
                --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1 \
                --region $AWS_REGION
        echo -e "Table ${ORANGE}${TERRAFORM_LOCK_TABLE}${NC} created successfully 🎉"
    fi

    set -e
}

function goal_apply-tf() {
    pushd "${SCRIPT_DIR}/infra/account" >/dev/null
        set +e
          cp main.tf main.backup
          sed -i '' "s/\$TERRAFORM_STATE_BUCKET/$TERRAFORM_STATE_BUCKET/" "main.tf"
          sed -i '' "s/\$TERRAFORM_LOCK_TABLE/$TERRAFORM_LOCK_TABLE/" "main.tf"
          terraform init -upgrade
          terraform apply
          mv main.backup main.tf
        set -e
    popd >/dev/null
}

function goal_destroy-tf() {
    pushd "${SCRIPT_DIR}/infra/account" >/dev/null
        set +e
          cp main.tf main.backup
          sed -i '' "s/\$TERRAFORM_STATE_BUCKET/$TERRAFORM_STATE_BUCKET/" "main.tf"
          sed -i '' "s/\$TERRAFORM_LOCK_TABLE/$TERRAFORM_LOCK_TABLE/" "main.tf"
          terraform init -upgrade
          terraform destroy
          mv main.backup main.tf
        set -e
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

function goal_set-backend-url() {
    if [[ -z $1 ]];then
        echo -e "${RED}ERROR${NC}> No backend URL provided!"
        return 1
    fi

    ESCAPED_URL=$(echo $1 | sed 's/\//\\\//g')

    cp ${SCRIPT_DIR}/configuration.json ${SCRIPT_DIR}/configuration.backup
    KEY="terraform_apigateway_domain"
    MATCHER="$KEY\"\: \"[^\"]*"
    echo -e "Setting ${ORANGE}${KEY}${NC} to ${ORANGE}${1}${NC}"
    sed -i '' "s/$MATCHER/$KEY\"\: \"$ESCAPED_URL\//" ${SCRIPT_DIR}/configuration.json
}

function goal_package-layer() {
    mkdir -p ${SCRIPT_DIR}/dist
    rm -rf ${SCRIPT_DIR}/tmp/layer
    mkdir -p ${SCRIPT_DIR}/tmp/layer/nodejs
    cp ${SCRIPT_DIR}/lambda/package.json ${SCRIPT_DIR}/tmp/layer/nodejs
    pushd ${SCRIPT_DIR}/tmp/layer/nodejs 2>&1>/dev/null
      # docker run --platform linux/amd64 -v "$PWD":/var/task lambci/lambda:build-nodejs12.x npm install --no-optional --only=prod
      npm install --no-optional --only=prod
    popd 2>&1>/dev/null
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
        echo -e "Uploading to bucket ${DIST_BUCKET}..."
        aws s3 sync dist/social s3://${DIST_BUCKET}${WEB_UI_BASE_HREF} --sse --delete --cache-control no-cache --exact-timestamps --exclude "index.html" --region eu-central-1 2>&1
        aws s3 cp dist/social/index.html s3://${DIST_BUCKET} --sse --cache-control "max-age=0" --region eu-central-1 2>&1
        echo -e "Upload to bucket ${DIST_BUCKET} completed"
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
