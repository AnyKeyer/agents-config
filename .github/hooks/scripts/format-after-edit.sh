#!/usr/bin/env bash
# format-after-edit.sh
# PostToolUse hook: auto-formats a file after the Executor edits it.
# Silently exits 0 on any error — never blocks the agent.
set -euo pipefail

input=$(cat)
[ -z "$input" ] && exit 0

# Require python3 for JSON parsing (more portable than jq)
command -v python3 &>/dev/null || exit 0

tool=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool', ''))
except:
    print('')
" 2>/dev/null)

# Only process file-editing operations
case "$tool" in
  replace_string_in_file|create_file|multi_replace_string_in_file) ;;
  *) exit 0 ;;
esac

file=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('toolInput', {}).get('filePath', ''))
except:
    print('')
" 2>/dev/null)

[ -z "$file" ] || [ ! -f "$file" ] && exit 0

ext="${file##*.}"

run_prettier() {
  local f="$1"
  # 1. Try local project prettier (node_modules/.bin)
  local dir
  dir=$(dirname "$f")
  while [ "$dir" != "/" ] && [ "$dir" != "." ]; do
    local bin="$dir/node_modules/.bin/prettier"
    if [ -x "$bin" ]; then
      "$bin" --write "$f" >/dev/null 2>&1 && return 0
    fi
    dir=$(dirname "$dir")
  done
  # 2. Try global prettier
  command -v prettier &>/dev/null && prettier --write "$f" >/dev/null 2>&1 || true
}

case "$ext" in
  ts|tsx|js|jsx|mjs|cjs|json|css|html|md|yml|yaml)
    run_prettier "$file"
    ;;
  py)
    if command -v ruff &>/dev/null; then
      ruff format "$file" >/dev/null 2>&1 || true
    elif command -v black &>/dev/null; then
      black "$file" >/dev/null 2>&1 || true
    fi
    ;;
  go)
    command -v gofmt &>/dev/null && gofmt -w "$file" >/dev/null 2>&1 || true
    ;;
  rs)
    command -v rustfmt &>/dev/null && rustfmt "$file" >/dev/null 2>&1 || true
    ;;
esac

exit 0
