#!/bin/bash

set -eo pipefail

if [[ ! -e "./composer.json" ]]; then
    cat >./composer.json <<EOL
{
    "scripts": {
        "build-assets": "echo 'No build assets step defined.'",
        "lint": "echo 'No lint step defined.'",
        "code-sniff": "echo 'No code sniff step defined.'",
        "unit-test": "echo 'No unit test step defined.'",
        "behat": "echo 'No behat step defined.'"
    }
}
EOL
fi
