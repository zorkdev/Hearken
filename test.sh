#!/usr/bin/env sh

set -euo pipefail

swift run swiftlint --strict --reporter emoji
swift run swift-doc coverage ./Sources | grep -q "Total[ $(printf '\t')]*100.00 %"
swift test --enable-test-discovery
