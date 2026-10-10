#!/bin/sh
set -eu
PROJECT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
if [ -n "${ERA_ZERO_NODE:-}" ] && [ -x "$ERA_ZERO_NODE" ]; then
  NODE_BIN=$ERA_ZERO_NODE
elif command -v node >/dev/null 2>&1; then
  NODE_BIN=$(command -v node)
elif [ -x "/Users/timetravellog/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node" ]; then
  NODE_BIN=/Users/timetravellog/.cache/codex-runtimes/codex-primary-runtime/dependencies/node/bin/node
else
  echo "No Node.js executable available for JavaScript syntax audit" >&2
  exit 1
fi
"$NODE_BIN" --check "$PROJECT_DIR/app/public/app.js"
"$NODE_BIN" --check "$PROJECT_DIR/pages/app.js"
"$NODE_BIN" --check "$PROJECT_DIR/pages/visemes.mjs"
echo "Product frontend syntax: PASS (local source, browser release, viseme compiler)"
