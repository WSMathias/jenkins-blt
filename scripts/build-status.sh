#!/bin/bash

STATUS_URL=$statuses_url
GITHUB_TOKEN=$github_token

echo "status $STATUS_URL"
echo "token $GITHUB_TOKEN"
echo "build status $BUILD_STATUS"

  curl "$STATUS_URL?access_token=$GITHUB_TOKEN" \
  -H "Content-Type: application/json" \
  -X POST \
  -d "{\"state\": \"$BUILD_STATUS\",\"context\": \"$JOB_CONTEXT\", \"description\": \"Jenkins\", \"target_url\": \"$JENKINS_URL/job/$JOB_NAME/$BUILD_NUMBER/console\"}"