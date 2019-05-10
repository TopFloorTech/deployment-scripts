#!/bin/bash

set -eo pipefail

#
# This script prepares the site-under-test by cloning the database from
# an existing site.
#
# Use EITHER this script OR the re-install-new script; do not run both.
#

# Create a new multidev site to test on

if [[ $WORKFLOW_ID == "build" ]]; then
    if [[ $BUILD_TYPE == "clone" ]]; then
        terminus -n env:wake "$TERMINUS_SITE.$BUILD_SOURCE_ENV"
        terminus -n build:env:create "$TERMINUS_SITE.$BUILD_SOURCE_ENV" "$TERMINUS_ENV" --yes --clone-content --notify="$NOTIFY"
    elif [[ $BUILD_TYPE == "install" ]]; then
        terminus -n build:env:create "$TERMINUS_SITE.$BUILD_SOURCE_ENV" "$TERMINUS_ENV" --yes --notify="$NOTIFY"
        terminus -n build:env:install "$TERMINUS_SITE.$TERMINUS_ENV" --site-name="$TEST_SITE_NAME" --account-mail="$ADMIN_EMAIL" --account-pass="$ADMIN_PASSWORD"
    fi
elif [[ $WORKFLOW_ID == "sync" ]]; then
    if [[ $PANTHEON_ENV_EXISTS == 0 ]]; then
      terminus -n env:wake "$TERMINUS_SITE.$TERMINUS_ENV"
    fi

    git fetch || true
    git push ${REMOTE_REPOSITORY} ${CIRCLE_SHA1}:refs/heads/${REMOTE_BRANCH}
fi
