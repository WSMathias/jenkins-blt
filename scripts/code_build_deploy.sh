#!/bin/bash

SOURCE_GIT_URL=$source_git_repo
SOURCE_BRANCH=$source_branch
ACQUIA_GIT_URL=$acquia_repo_url
ACQUIA_BRANCH=$acquia_branch
REPO_NAME=$repo_name
DRUSH="$WORKSPACE/$repo_name/vendor/bin/drush"
AC_ENV="@$acquia_env"
AC_ALIAS=$mulsite_option


code_build_deploy()
{
    cd $WORKSPACE/$REPO_NAME
    echo  "Starting BLT test cases "
    #  composer run-script blt-alias
    ./vendor/bin/blt blt:init:shell-alias -n
    #blt setup:behat
    source ~/.bash_profile
    echo  "Build preparation process is completed, starting deployment ..."
    blt artifact:deploy --commit-msg "Deployment completed on $ACQUIA_BRANCH" --branch $ACQUIA_BRANCH --no-interaction
    if [ $? -ne "0" ]
    then
        echo "Deployment failed."
        exit 1
    else
        echo  "Deployment completed."
    fi
}

code_build_deploy