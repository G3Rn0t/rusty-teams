#!/usr/bin/env bash
# Fail when product behaviour sources change without an OpenSpec touch in the
# same range. Agents ignore markdown rules; CI does not.
#
# Usage:
#   scripts/check-openspec-gate.sh              # working tree / index vs HEAD
#   scripts/check-openspec-gate.sh origin/main  # commits since base (PR / push)
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

base="${1:-}"
if [[ -n "$base" ]]; then
  range="${base}...HEAD"
  mapfile -t changed < <(git diff --name-only "$range" -- . ':!vendor' || true)
else
  mapfile -t changed < <(git diff --name-only HEAD -- . ':!vendor'; git diff --name-only --cached -- . ':!vendor' | sort -u)
fi

behavior=0
openspec=0
for path in "${changed[@]:-}"; do
  [[ -z "$path" ]] && continue
  case "$path" in
    openspec/changes/*|openspec/specs/*)
      openspec=1
      ;;
    crates/app/*|crates/app-base/*|crates/app-state/*|crates/app-call-model/*|crates/app-ui-kit/*|crates/calling/*|crates/browser/*|crates/session/*|crates/chatsvc/*|crates/graph/*|crates/core/*|crates/webview/*)
      case "$path" in
        *.rs|*/locales/*|*.yml|*.yaml)
          behavior=1
          ;;
      esac
      ;;
  esac
done

if [[ "$behavior" -eq 1 && "$openspec" -eq 0 ]]; then
  cat >&2 <<'EOF'
OpenSpec gate failed.

Product sources under crates/ changed, but nothing under openspec/changes/ or
openspec/specs/ changed in the same range.

Required (AGENTS.md, .cursor/rules/openspec-first.mdc):
  1. Create openspec/changes/<name>/ (proposal, design, tasks, spec deltas)
  2. openspec validate <name>
  3. Implement
  4. After merge: openspec archive <name> -y

Pure refactor / tooling / docs-only: add skip_specs: true in the change
.openspec.yaml and still touch openspec/changes/, or avoid crates/ behaviour
paths.

EOF
  exit 1
fi

echo "OpenSpec gate OK (behavior=${behavior} openspec=${openspec})"
