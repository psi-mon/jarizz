#!/usr/bin/env bash
# Run acceptance tests for a given feature file.
# Usage: scripts/run-acceptance.sh <feature-file>
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APS_TOOLS_DIR="$REPO_ROOT/tmp"
GHERKIN_PARSER="$APS_TOOLS_DIR/gherkin-parser"
FEATURE_FILE="${1:?Usage: $0 <feature-file>}"
FEATURE_NAME="$(basename "$FEATURE_FILE" .feature)"
BUILD_DIR="$REPO_ROOT/build/acceptance"
IR_FILE="$BUILD_DIR/ir/$FEATURE_NAME.json"
GENERATED_DIR="$BUILD_DIR/generated"

mkdir -p "$BUILD_DIR/ir" "$GENERATED_DIR"

printf 'Parsing %s -> %s\n' "$FEATURE_FILE" "$IR_FILE"
"$GHERKIN_PARSER" "$FEATURE_FILE" "$IR_FILE"

printf 'Running acceptance tests\n'
cd "$REPO_ROOT"
JARIZZ_FEATURE_JSON="$IR_FILE" \
JARIZZ_GENERATED_DIR="$GENERATED_DIR" \
swift test \
  --scratch-path "$REPO_ROOT/.build" \
  --filter JarizzAcceptanceTests
