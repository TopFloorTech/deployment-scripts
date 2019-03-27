#!/bin/bash

set -eo pipefail

# Delete leftover CI environments
terminus -n build:env:delete:ci "$TERMINUS_SITE" --keep=2 --yes
