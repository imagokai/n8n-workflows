#!/usr/bin/env bash
# Replace __WF_*__ placeholders in workflows/*.json with values from config.env,
# and write the results to build/.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$REPO_DIR/build"
CONFIG_FILE="$REPO_DIR/config.env"

if [[ ! -f "$CONFIG_FILE" ]]; then
  echo "config.env not found, copy config.example.env to config.env and fill it in" >&2
  exit 1
fi
set -a
source "$CONFIG_FILE"
set +a

rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

for file in "$REPO_DIR"/workflows/*.json; do
  jq '
    walk(
      if type == "string" then
        gsub("__(?<name>WF_[A-Z0-9_]+)__";
          if ($ENV[.name] // "") == "" then error("\(.name) is not set") else $ENV[.name] end)
      else . end)
  ' "$file" > "$BUILD_DIR/$(basename "$file")"
done

echo "Workflows written to $BUILD_DIR"
