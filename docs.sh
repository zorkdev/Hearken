#!/usr/bin/env sh

set -euo pipefail

rm -R ./docs

swift run swift-doc generate ./Sources \
    --module-name Hearken \
    --output ./docs \
    --format html \
    --base-url https://zorkdev.github.io/Hearken/
