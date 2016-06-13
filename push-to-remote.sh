#!/bin/bash
# Deploy to via pushing to a remote git repository.
#
# Add the following environment variables to your project configuration and make
# sure the public SSH key from your projects General settings page is allowed to
# push to the remote repository as well.
# * REMOTE_REPOSITORY, e.g. "git@github.com:codeship/documentation.git"
# * REMOTE_BRANCH, e.g. "production"
#
# Include in your builds via
# \curl -sSL https://raw.githubusercontent.com/TopFloorTech/deployment-scripts/master/git-push-to-remote.sh | bash -s
REMOTE_REPOSITORY=${REMOTE_REPOSITORY:?'You need to configure the REMOTE_REPOSITORY environment variable!'}

if [ -n $CIRCLE_BRANCH ]; then
  REMOTE_BRANCH=$CIRCLE_BRANCH
else
  REMOTE_BRANCH=${REMOTE_BRANCH:?'You need to configure the REMOTE_BRANCH environment variable if you're not pushing a branch!'}
fi

set -e

git fetch --unshallow || true
git push ${REMOTE_REPOSITORY} ${CIRCLE_SHA1}:${REMOTE_BRANCH}
