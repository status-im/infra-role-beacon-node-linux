#!/usr/bin/env bash
set -euo pipefail

REPO_URL="$1"
BRANCH="$2"
TARGET="$3"
shift 3 # remaining args passed through to nix build

REV=$(git ls-remote "$REPO_URL" "$BRANCH" | awk '{print $1}')
[[ -z "$REV" ]] && { echo "Failed to resolve '$BRANCH' in $REPO_URL" >&2; exit 1; }

# rev is used because of a known issue with missing git info when using ref:
# https://github.com/NixOS/nix/issues/15875
exec /nix/var/nix/profiles/default/bin/nix build "$@" "git+${REPO_URL}?submodules=1&rev=${REV}#${TARGET}"