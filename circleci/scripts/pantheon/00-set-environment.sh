#!/bin/bash

set -eo pipefail

# Avoid ssh prompting when connecting to new ssh hosts
mkdir -p $HOME/.ssh && echo "StrictHostKeyChecking no" >> "$HOME/.ssh/config"

# Configure the GitHub Oauth token if it is available
if [ -n "$GITHUB_TOKEN" ] ; then
  composer -n config --global github-oauth.github.com $GITHUB_TOKEN
fi

# Set up our default git config settings.
git config --global user.email "$GIT_EMAIL"
git config --global user.name "Circle CI"
git config --global core.fileMode false

# Set up environment variables

if [[ -z $WORKFLOW_ID ]]; then
    WORKFLOW_ID='build'
fi

if [[ -z $BUILD_TYPE ]]; then
    BUILD_TYPE="clone"
fi

if [[ -z $BUILD_SOURCE_ENV ]]; then
    BUILD_SOURCE_ENV="dev"
fi

if [[ -z $SITE_PLATFORM ]]; then
    SITE_PLATFORM="drupal"
fi

if [[ -z $MESSAGE ]]; then
    if [[ $WORKFLOW_ID == "build" ]]; then
        MESSAGE='Created multidev environment [{site}#{env}]({dashboard-url}).'
    else
        MESSAGE='Synced to multidev environment [{site}#{env}]({dashboard-url}).'
    fi
fi

NOTIFY='scripts/github/add-commit-comment {project} {sha} "'"$MESSAGE"'" {site-url}'

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
  echo "export WORKFLOW_ID='$WORKFLOW_ID'"
  echo "export BUILD_TYPE='$BUILD_TYPE'"
  echo "export BUILD_SOURCE_ID='$BUILD_SOURCE_ID'"
  echo "export SITE_PLATFORM='$SITE_PLATFORM'"
  echo 'export PATH=$PATH:$HOME/bin'
  echo 'export TERMINUS_HIDE_UPDATE_MESSAGE=1'
  echo 'export TERMINUS_ENV=${TERMINUS_ENV:-$DEFAULT_ENV}'
  echo "export NOTIFY='$NOTIFY'"
) >> $BASH_ENV
source $BASH_ENV

# Re-install the Terminus Build Tools plugin if requested
if [ -n $BUILD_TOOLS_VERSION ] && [ "$BUILD_TOOLS_VERSION" <> 'dev-master' ]; then
  echo "Install Terminus Build Tools Plugin version $BUILD_TOOLS_VERSION"
  rm -rf ${TERMINUS_PLUGINS_DIR:-~/.terminus/plugins}/terminus-build-tools-plugin
  composer -n create-project -d ${TERMINUS_PLUGINS_DIR:-~/.terminus/plugins} pantheon-systems/terminus-build-tools-plugin:$BUILD_TOOLS_VERSION
fi
