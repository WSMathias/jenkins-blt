#!/bin/bash

SOURCE_GIT_URL=$source_git_repo
SOURCE_BRANCH=$source_branch
ACQUIA_GIT_URL=$acquia_repo_url
ACQUIA_BRANCH=$acquia_branch
REPO_NAME=$repo_name
DRUSH="$WORKSPACE/$repo_name/vendor/bin/drush"
AC_ENV="@$acquia_env"
AC_ALIAS=$mulsite_option
CIM_CHECK="$cim_hook"

setup_blt()
{
    cd $WORKSPACE
    rm -rf $repo_name
    git clone -b $SOURCE_BRANCH $SOURCE_GIT_URL $repo_name
    echo "Rep setup completed."

    # Install blt
    cd $repo_name
    composer install
    if [ $? != 0 ]
    then
        echo "blt setup failed, Please check manually."
        exit 1
    fi

    ./vendor/bin/blt blt:init:shell-alias -n
    source ~/.bash_profile
    echo "BLT installation completed."
}

pattern_lab()
{
    if [ $build_pattern_lab == "true" ]
    then
    {
        sed -i "s/BUILD_PATTERN_LAB/${build_pattern_lab}/g" scripts/custom/frontend_build.sh
    }
    fi
}

update_hooks_config()
{
    if [ -d "./hooks" ]
    then
        sed -i 's/run_cim="false"/run_cim="config_sync"/g' hooks/common/post-code-update/post-code-update.sh
        sed -i 's/run_cim="true"/run_cim="config_sync"/g' hooks/common/post-code-update/post-code-update.sh

        sed -i 's/run_cim="false"/run_cim="config_sync"/g' hooks/common/post-code-deploy/post-code-deploy.sh
        sed -i 's/run_cim="true"/run_cim="config_sync"/g' hooks/common/post-code-deploy/post-code-deploy.sh

        sed -i "s/default/${mulsite_option}/g"  hooks/common/post-code-update/post-code-update.sh
        sed -i "s/default/${mulsite_option}/g"  hooks/common/post-code-deploy/post-code-deploy.sh
        sed -i "s/config_sync/$cim_hook/g" hooks/common/post-code-update/post-code-update.sh
        sed -i "s/config_sync/$cim_hook/g" hooks/common/post-code-deploy/post-code-deploy.sh
    else
        echo "Acquia cloud hooks are not yet configured"
    fi

    ## remove this line in future
    #  sed -i.bkp "s/msite_option -y/msite_option -n/g" scripts/functions.sh
    #  sed -i.bkp "s/-D site/--site/g" scripts/functions.sh
    echo $USER
    cp $HOME/scripts/functions.sh scripts/functions.sh

    rm -rf .git/hooks/pre-commit
    rm -rf .git/hooks/commit-msg
    git add .
    git commit -m "By pass blt validation for uncommitted files."
    echo " All file commited"
}

branch_not_exist()
{
    echo "Starting fresh setup for the test. Calling setup_blt function"
    setup_blt
    pattern_lab
    update_hooks_config
    ##### Change the frontend settings for the Multisite
    #  git add scripts/custom/frontend_build.sh
    #  cd blt
    #  sed -i "s/acquia_remote_placeholder/${ACQUIA_GIT_URL}/g" blt/blt.yml
    #  git add blt.yml
    #  git commit -m "make blt aware of acquia git url."
}

branch_exist()
{
    echo "Only pulling the latest changes"
    cd $WORKSPACE/$REPO_NAME
    git pull origin $BRANCH
    if [ $? -ne "0" ]
    then
        echo "Git pull is not executing properly."
        branch_not_exist
        echo "Git pull was not working properly so running the job from begining"
        exit 0
    fi
    sed -i "s/acquia_remote_placeholder/${ACQUIA_GIT_URL}/g" blt/blt.yml
    update_hooks_config
}


check_branch()
{
    echo "Inside Check_branch to check which branch is currently tested"
    cd $WORKSPACE/$REPO_NAME
    if [ $? == "0" ]
    then
        BRANCH=$(git rev-parse --abbrev-ref HEAD)
    else
        BRANCH="None"
    fi

    echo "current branch --> $BRANCH at $WORKSPACE/$REPO_NAME"
        if [[ "$BRANCH" != "$SOURCE_BRANCH" ]] || [[ $force_update == "true" ]]; then
    echo "Branch specified in the Job is different then the last tested branch. Calling branch_not_exist function."
        branch_not_exist
    else
    echo "Branch specified in the Job is same to the last tested branch. Calling branch_exist function."
        branch_exist
    fi
}

check_branch