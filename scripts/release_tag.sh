#!/bin/bash

SOURCE_GIT_URL=$source_git_repo
SOURCE_BRANCH=$source_branch
ACQUIA_GIT_URL=$acquia_repo_url
ACQUIA_BRANCH=$acquia_branch
REPO_NAME=$repo_name
DRUSH="$WORKSPACE/$REPO_NAME/vendor/bin/drush"
AC_ENV="@$acquia_env"
AC_ALIAS=$mulsite_option
RELEASE_TAG=$release_tag
RELEASE_MSG=$release_name


cd $WORKSPACE/$REPO_NAME
git tag -a $RELEASE_TAG -m "release: release_name"  origin/$SOURCE_BRANCH && \
git push origin $RELEASE_TAG && \
git tag -d $RELEASE_TAG  # to avoid tag conflict with blt
if [ $? -ne "0" ]
then
    echo "failed tag sorce repo"
    exit 1
else
    echo  "successfully pushed tag to sorce repo"
fi
composer install  ## optimization
./vendor/bin/blt artifact:deploy --commit-msg "New release: $RELEASE_MSG" --tag "$RELEASE_TAG" --no-interaction
if [ $? -ne "0" ]
then
    echo "pushing tag to aquia failed."
    git push origin :$RELEASE_TAG
    exit 1
else
    echo  "successfully pushed  tag to acquia"
fi
