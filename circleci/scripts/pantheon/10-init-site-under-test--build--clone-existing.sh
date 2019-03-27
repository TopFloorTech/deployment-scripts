#!/bin/bash

set -eo pipefail

#
# This script prepares the site-under-test by cloning the database from
# an existing site.
#
# Use EITHER this script OR the re-install-new script; do not run both.
#

# Create a new multidev site to test on
terminus -n env:wake "$TERMINUS_SITE.dev"
terminus -n build:env:create "$TERMINUS_SITE.dev" "$TERMINUS_ENV" --yes --clone-content --notify="$NOTIFY"
