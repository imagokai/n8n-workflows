#!/usr/bin/env bash
# Import build/ into a running n8n.
# Usage:
#   ./import.sh local
#   ./import.sh docker /path/to/n8n-compose
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$REPO_DIR/build"
MODE="${1:-}"

usage() {
  echo "usage: ./import.sh local | docker /path/to/n8n-compose" >&2
  exit 1
}

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "build/ not found, run ./build.sh first" >&2
  exit 1
fi

case "$MODE" in
  local)
    if [[ $# -ne 1 ]]; then
      usage
    fi
    if ! command -v n8n >/dev/null 2>&1; then
      echo "n8n command not found" >&2
      exit 1
    fi
    n8n import:workflow --separate --input="$BUILD_DIR"
    ;;
  docker)
    COMPOSE_DIR="${2:-}"
    if [[ $# -ne 2 || ! -d "$COMPOSE_DIR" ]]; then
      usage
    fi
    cd "$COMPOSE_DIR"
    docker compose cp "$BUILD_DIR" n8n:/tmp/build
    docker compose exec n8n n8n import:workflow --separate --input=/tmp/build
    docker compose exec -u root n8n rm -rf /tmp/build
    ;;
  *)
    usage
    ;;
esac

echo "Workflows imported"
