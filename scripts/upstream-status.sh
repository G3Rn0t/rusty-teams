#!/usr/bin/env bash
# Compare Upstream main (danieldaeschle/rusty-teams) to Forgejo main.
# Prints "in sync" or the ahead commit list. Exit 0 on a successful compare;
# non-zero only when fetch/compare fails.
#
# Usage (from repo root or any cwd):
#   scripts/upstream-status.sh
#
# Optional env:
#   UPSTREAM_REMOTE   default: upstream (URL if remote missing:
#                     https://github.com/danieldaeschle/rusty-teams.git)
#   UPSTREAM_REF      default: main
#   FORK_REF          default: origin/main if it exists, else main
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT"

upstream_remote="${UPSTREAM_REMOTE:-upstream}"
upstream_ref="${UPSTREAM_REF:-main}"
upstream_url="${UPSTREAM_URL:-https://github.com/danieldaeschle/rusty-teams.git}"

if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "Not a git repository: $ROOT" >&2
  exit 1
fi

if ! git remote get-url "$upstream_remote" >/dev/null 2>&1; then
  echo "Adding remote '$upstream_remote' → $upstream_url"
  git remote add "$upstream_remote" "$upstream_url"
fi

echo "Fetching $upstream_remote/$upstream_ref …"
git fetch --quiet "$upstream_remote" "$upstream_ref"

upstream_tip="$upstream_remote/$upstream_ref"
if ! git rev-parse --verify "$upstream_tip" >/dev/null 2>&1; then
  echo "Missing ref after fetch: $upstream_tip" >&2
  exit 1
fi

if [[ -n "${FORK_REF:-}" ]]; then
  fork_ref="$FORK_REF"
elif git rev-parse --verify origin/main >/dev/null 2>&1; then
  fork_ref="origin/main"
elif git rev-parse --verify main >/dev/null 2>&1; then
  fork_ref="main"
else
  echo "No Forgejo/base ref (set FORK_REF or create origin/main)." >&2
  exit 1
fi

ahead="$(git rev-list --count "$fork_ref..$upstream_tip")"
if [[ "$ahead" -eq 0 ]]; then
  echo "In sync: $fork_ref already contains $upstream_tip"
  exit 0
fi

echo "Upstream ahead: $ahead commit(s) on $upstream_tip not in $fork_ref"
echo
git log --format='%ad %h %s' --date=short "$fork_ref..$upstream_tip"
echo
echo "Merge consciously when ready:"
echo "  git fetch $upstream_remote"
echo "  git checkout main"
echo "  git merge $upstream_tip"
echo "  git push origin main"
