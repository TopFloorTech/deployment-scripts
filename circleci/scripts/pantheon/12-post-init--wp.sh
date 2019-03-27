#!/bin/bash

set -eo pipefail

#
# This script prepares the site-under-test by cloning the database from
# an existing site.
#
# Use EITHER this script OR the re-install-new script; do not run both.
#

# Create a new multidev site to test on
terminus -n env:wake "$TERMINUS_SITE.$TERMINUS_ENV"

git fetch --unshallow || true
git push ${REMOTE_REPOSITORY} ${CIRCLE_SHA1}:${REMOTE_BRANCH}

# Run updatedb to ensure that the database is updated for the new code.
terminus -n wp "$TERMINUS_SITE.$TERMINUS_ENV" -- core update-db -y

# If any modules, or theme files have been moved around or reorganized, in order to avoid
# "The website encountered an unexpected error. Please try again later." error on First Visit
terminus -n wp "$TERMINUS_SITE.$TERMINUS_ENV" cache flush -y
