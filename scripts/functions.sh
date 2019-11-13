#!/bin/bash
# Common functions for cloud hooks.

status=0

drush_alias=${site}'.'${target_env}


deploy_updates() {

echo "Running updates for environment: $target_env"

# Prep for BLT commands.
repo_root="/var/www/html/$site.$target_env"
export PATH=$repo_root/vendor/bin:$PATH
cd $repo_root/docroot

  if [ $msite_option == "all" ] ; then
        multi_sites=`find ./sites/ -mindepth 1 -maxdepth 1 -type d -printf '%f\n'`
        for i in $multi_sites
        do
            #blt deploy:update --define environment=$target_env -v -y
            echo "Deploying updates to ============= $i"
            drush cr drush --uri=$i --yes
            echo "drush cache was cleared"
            drush cache-rebuild --uri=$i --yes
            echo "Cache rebuild complete"
            drush updb --uri=$i --yes
            echo "DB updates done"
            #drush config-import sync --uri=$i --yes
            echo "Completed the config import sync process"
	    done
  elif [ $msite_option == "default"  ] ; then
        #blt deploy:update --define environment=$target_env -v -y -D site=$msite_option
        echo "Running drupal module enable/disable script as per environment and config defined in project.yml"
        blt setup:toggle-modules --define environment=$target_env -v --site=$msite_option -n
        echo "Deploying updates to $msite_option"
        drush cr drush --uri=$msite_option --yes
        echo "drush cache was cleared"
        drush cache-rebuild --uri=$msite_option --yes
        echo "Cache rebuild complete"
        drush updb --uri=$msite_option --yes
        echo "DB updates done"
		if [ $run_cim == "true" ]
		then
            echo "cim is enabled for the default site"
            # drush config-import sync --uri=$msite_option --yes
            echo "Completed the config import sync process."
		fi
  else
        echo "Deploying updates to ===== $msite_option"
        echo "Running drupal module enable/disable script as per environment and config defined in project.yml"
        blt setup:toggle-modules --define environment=$target_env -v --site=$msite_option -n
        drush cr drush --uri=$msite_option --yes
        echo "drush cache was cleared for site ===== $msite_option"
        drush cache-rebuild --uri=$msite_option --yes
        echo "Cache rebuild completed for site ===== $msite_option"
        drush updb --uri=$msite_option --yes
        echo "DB updates done for site ===== $msite_option"
		if [ $run_cim == "true" ]
        then
            echo "cim is enabled for the site ===== $msite_option"
            drush config-import sync --uri=$msite_option --yes
            echo "Completed the config import sync process for site ===== $msite_option"
        fi
  fi

  if [ $? -ne 0 ]; then
      echo "Update errored."
      exit 1
  fi

  echo "Finished updates for environment: $target_env"
}

