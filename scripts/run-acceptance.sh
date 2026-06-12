#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GOPATH_BIN="$(go env GOPATH)/bin"
export PATH="$PATH:$GOPATH_BIN"

mkdir -p "$ROOT/build/acceptance/ir" "$ROOT/acceptance/generated"

echo "=== Parsing feature files ==="
for f in $(find "$ROOT/features" -name "*.feature" 2>/dev/null); do
  [[ -f "$f" ]] || continue
  base=$(basename "$f" .feature)
  gherkin-parser "$f" "$ROOT/build/acceptance/ir/${base}.json"
  echo "  parsed: $f"
done

echo "=== Generating acceptance entrypoints ==="
rm -f "$ROOT/acceptance/generated/"*.swift
for ir in "$ROOT/build/acceptance/ir/"*.json; do
  [[ -f "$ir" ]] || continue
  "$ROOT/acceptance-entrypoint-generator" "$ir" "$ROOT/acceptance/generated/"
done

echo "=== Running acceptance tests ==="
swift test --filter AcceptanceTests 2>&1

echo "=== Done ==="
