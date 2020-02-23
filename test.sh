#!/usr/bin/env sh

set -euo pipefail

swift run swiftlint --strict --reporter emoji
swift test --enable-test-discovery
