#!/bin/bash

set -eo pipefail

#
# This script starts up the test process.
#
# - Environment settings (e.g. git config) are initialized
# - Terminus plugins are installed
# - Any needed code updates are done
#
echo "Begin build for $DEFAULT_ENV. Pantheon test environment is $TERMINUS_SITE.$TERMINUS_ENV"

# Log in via Terminus
terminus -n auth:login --machine-token="$TERMINUS_TOKEN"
