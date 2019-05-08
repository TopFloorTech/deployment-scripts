#!/bin/bash

set -eo pipefail

if [[ $PANTHEON_ENV_EXISTS == 0 ]]; then
  if [[ $SITE_PLATFORM == "drupal" || $SITE_PLATFORM == "drupal7" ]]; then
      # Run updatedb to ensure that the database is updated for the new code.
      terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" -- updatedb -y

      if [[ $SITE_PLATFORM == "drupal" ]]; then
          # If any modules, or theme files have been moved around or reorganized, in order to avoid
          # "The website encountered an unexpected error. Please try again later." error on First Visit
          terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" cr

          # If exported configuration is available, then import it.
          if [ -f "config/system.site.yml" ] ; then
            terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" -- config-import --yes
          fi
      elif [[ $SITE_PLATFORM == "drupal7" ]]; then
          # If any modules, or theme files have been moved around or reorganized, in order to avoid
          # "The website encountered an unexpected error. Please try again later." error on First Visit
          terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" cc all
      fi
  elif [[ $SITE_PLATFORM == "wordpress" ]]; then
      # Run updatedb to ensure that the database is updated for the new code.
      terminus -n wp "$TERMINUS_SITE.$TERMINUS_ENV" -- core update-db -y

      # If any modules, or theme files have been moved around or reorganized, in order to avoid
      # "The website encountered an unexpected error. Please try again later." error on First Visit
      terminus -n wp "$TERMINUS_SITE.$TERMINUS_ENV" -- cache flush -y
  fi
fi
