#!/usr/bin/env sh

set -euo pipefail

{
    sourcekitten doc --spm-module Hearken;
    echo ',';
    sourcekitten doc --spm-module HearkenTestKit;
} > docs.json
jazzy --sourcekitten-sourcefile docs.json --config .jazzy.yml
rm docs.json
