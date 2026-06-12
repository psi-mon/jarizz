#!/usr/bin/env bash
# gherkin-mutator persistent runner adapter for jarizz Swift/XCTest acceptance tests.
# Reads newline-delimited JSON job requests from stdin, writes responses to stdout.
# Diagnostics go to stderr. See mutator-spec.md for the worker protocol.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

while IFS= read -r line; do
    [[ -z "$line" ]] && continue

    id=$(printf '%s' "$line" | python3 -c "import sys,json; print(json.load(sys.stdin)['id'])")
    feature_json=$(printf '%s' "$line" | python3 -c "import sys,json; print(json.load(sys.stdin)['feature_json'])")
    generated_dir=$(printf '%s' "$line" | python3 -c "import sys,json; print(json.load(sys.stdin)['generated_dir'])")

    printf 'runner-worker: job %s\n' "$id" >&2

    start_ns=$(python3 -c "import time; print(int(time.monotonic() * 1_000_000_000))")

    output=$(cd "$REPO_ROOT" && \
             JARIZZ_FEATURE_JSON="$feature_json" \
             JARIZZ_GENERATED_DIR="$generated_dir" \
             swift test \
               --scratch-path "$REPO_ROOT/.build" \
               --filter JarizzAcceptanceTests 2>&1) && exit_code=0 || exit_code=$?

    end_ns=$(python3 -c "import time; print(int(time.monotonic() * 1_000_000_000))")
    duration=$(( end_ns - start_ns ))

    if [[ "$exit_code" -eq 0 ]]; then
        outcome="test_success"
    else
        outcome="test_failure"
    fi

    python3 -c "
import sys, json
data = {'id': sys.argv[1], 'outcome': sys.argv[2], 'output': sys.argv[3], 'error': '', 'duration': int(sys.argv[4])}
print(json.dumps(data))
" "$id" "$outcome" "$output" "$duration"
done
