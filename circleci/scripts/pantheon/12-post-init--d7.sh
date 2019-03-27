#!/bin/bash

set -eo pipefail

# Run updatedb to ensure that the database is updated for the new code.
terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" -- updatedb -y

# If any modules, or theme files have been moved around or reorganized, in order to avoid
# "The website encountered an unexpected error. Please try again later." error on First Visit
terminus -n drush "$TERMINUS_SITE.$TERMINUS_ENV" cc all
