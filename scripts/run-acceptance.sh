#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GOPATH_BIN="$(go env GOPATH)/bin"
export PATH="$PATH:$GOPATH_BIN"

TRACKED_IR_DIR="$ROOT/Tests/JarizzAcceptanceTests/ir"
mkdir -p "$ROOT/build/acceptance/ir" "$TRACKED_IR_DIR" "$ROOT/Tests/JarizzAcceptanceTests"

echo "=== Parsing feature files ==="
for f in $(find "$ROOT/features" -name "*.feature" 2>/dev/null); do
  base=$(basename "$f" .feature)
  gherkin-parser "$f" "$ROOT/build/acceptance/ir/${base}.json"
  cp "$ROOT/build/acceptance/ir/${base}.json" "$TRACKED_IR_DIR/${base}.json"
  echo "  parsed: $f"
done

echo "=== Generating acceptance entrypoints ==="
GENERATED_DIR="$ROOT/Tests/JarizzAcceptanceTests"
# cd to ROOT so compiledIRPath in generated tests is relative to the package root,
# matching the working directory used by swift test.
cd "$ROOT"
for ir in "$TRACKED_IR_DIR/"*.json; do
  [[ -f "$ir" ]] || continue
  "$ROOT/acceptance-entrypoint-generator" "$ir" "$GENERATED_DIR"
done

echo "=== Running acceptance tests ==="
swift test --filter JarizzAcceptanceTests 2>&1

echo "=== Done ==="
