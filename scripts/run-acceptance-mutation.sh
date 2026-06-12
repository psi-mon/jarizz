#!/usr/bin/env bash
# Run acceptance mutation for a given feature file.
# Usage: scripts/run-acceptance-mutation.sh <feature-file> [--level soft|hard|full]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APS_TOOLS_DIR="$REPO_ROOT/tmp"
GHERKIN_PARSER="$APS_TOOLS_DIR/gherkin-parser"
GHERKIN_MUTATOR="$APS_TOOLS_DIR/gherkin-mutator"
FEATURE_FILE="${1:?Usage: $0 <feature-file> [--level soft|hard|full]}"
LEVEL="${2:-hard}"
FEATURE_NAME="$(basename "$FEATURE_FILE" .feature)"
WORK_DIR="$REPO_ROOT/build/acceptance-mutation"
GENERATED_DIR="$WORK_DIR/generated"

mkdir -p "$WORK_DIR/ir" "$GENERATED_DIR"

printf 'Parsing %s\n' "$FEATURE_FILE"
IR_FILE="$WORK_DIR/ir/$FEATURE_NAME.json"
"$GHERKIN_PARSER" "$FEATURE_FILE" "$IR_FILE"

RUNNER_ADAPTER="$REPO_ROOT/acceptance/runner-adapter/runner-worker.sh"

printf 'Running acceptance mutation (level=%s)\n' "$LEVEL"
"$GHERKIN_MUTATOR" \
  --feature "$FEATURE_FILE" \
  --work-dir "$WORK_DIR" \
  --generated-dir "$GENERATED_DIR" \
  --level "$LEVEL" \
  --runner-worker "$RUNNER_ADAPTER" \
  --status-interval 10s \
  --workers 8
