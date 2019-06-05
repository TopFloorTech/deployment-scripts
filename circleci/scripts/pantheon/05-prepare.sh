#!/bin/bash

set -eo pipefail

#
# This script starts up the test process.
#
# - Environment settings (e.g. git config) are initialized
# - Terminus plugins are installed
# - Any needed code updates are done
#

# Log in via Terminus
terminus -n auth:login --machine-token="$TERMINUS_TOKEN"

if [[ $WORKFLOW_ID == 'sync' ]]; then
    DEFAULT_ENV=$CIRCLE_BRANCH

    if [[ "$DEFAULT_ENV" == "master" ]]; then
      DEFAULT_ENV="dev"
    fi

    if [[ -z $REMOTE_REPOSITORY ]]; then
      REMOTE_REPOSITORY=$(terminus -n connection:info --field git_url "$TERMINUS_SITE.$DEFAULT_ENV")
    fi

    REMOTE_REPOSITORY=${REMOTE_REPOSITORY:?'You need to configure the REMOTE_REPOSITORY environment variable!'}

    if [[ -z $REMOTE_BRANCH ]]; then
      if [[ -n $CIRCLE_BRANCH ]]; then
        REMOTE_BRANCH=$CIRCLE_BRANCH
      fi
    fi
    REMOTE_BRANCH=${REMOTE_BRANCH:?'You need to configure the REMOTE_BRANCH environment variable if you are not pushing a branch!'}

    terminus env:info $TERMINUS_SITE:$TERMINUS_ENV && true
    PANTHEON_ENV_EXISTS=$?
else
    DEFAULT_ENV=ci-$CIRCLE_BUILD_NUM
    REMOTE_REPOSITORY=""
    REMOTE_BRANCH=""
    PANTHEON_ENV_EXISTS=0

    # Delete leftover CI environments
    terminus -n build:env:delete:ci "$TERMINUS_SITE" --keep=2 --yes
fi

echo "Begin build for $DEFAULT_ENV. Pantheon test environment is $TERMINUS_SITE.$TERMINUS_ENV"

#=====================================================================================================================
# EXPORT needed environment variables
#
# Circle CI 2.0 does not yet expand environment variables so they have to be manually EXPORTed
# Once environment variables can be expanded this section can be removed
# See: https://discuss.circleci.com/t/unclear-how-to-work-with-user-variables-circleci-provided-env-variables/12810/11
# See: https://discuss.circleci.com/t/environment-variable-expansion-in-working-directory/11322
# See: https://discuss.circleci.com/t/circle-2-0-global-environment-variables/8681
#=====================================================================================================================
(
  echo "export DEFAULT_ENV='$DEFAULT_ENV'"
  echo 'export TERMINUS_ENV=${TERMINUS_ENV:-$DEFAULT_ENV}'
  echo "export REMOTE_REPOSITORY='$REMOTE_REPOSITORY'"
  echo "export REMOTE_BRANCH='$REMOTE_BRANCH'"
  echo "export PANTHEON_ENV_EXISTS='$PANTHEON_ENV_EXISTS'"
) >> $BASH_ENV
source $BASH_ENV
