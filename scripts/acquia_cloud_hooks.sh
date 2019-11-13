#!/bin/bash

SOURCE_GIT_URL=$source_git_repo
SOURCE_BRANCH=$source_branch
ACQUIA_GIT_URL=$acquia_repo_url
ACQUIA_BRANCH=$acquia_branch
REPO_NAME=$repo_name
DRUSH="$WORKSPACE/$repo_name/vendor/bin/drush"
AC_ENV="@$acquia_env"
AC_ALIAS=$mulsite_option

echo " checking drush value ====== $DRUSH"
Chk_acquia_hooks()
{
        sleep 5
        TASKID=`$DRUSH $AC_ENV  ac-task-list | grep -i "Deployment completed on $ACQUIA_BRANCH" | tail -n 1 | awk -F ":" '{print $1}'`
        echo  "Testing Task ID--> $TASKID"
        while true
         TSTATE=`$DRUSH $AC_ENV ac-task-info $TASKID | grep state | awk -F ':' '{print $2}'`
         echo  "Testing Task state--> $TASKID"
         do
         if [ $TSTATE == "failed" ]
         then
           $DRUSH $AC_ENV ac-task-info $TASKID
           echo "Look up Acquia console logs for acquia cloud hook failure."
            cd $WORKSPACE/$REPO_NAME
            git checkout .
           exit 1
         elif [ $TSTATE == "done" ]
         then
           echo "Acquia Cloud hook run succesfully."
           break
         fi
        exit 1
        done
}

Chk_acquia_hooks