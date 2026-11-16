#!/usr/bin/env bash
# Forgejo Actions helper: compare Upstream main to this checkout (Forgejo main)
# and open/update a single "Upstream ahead:" issue. Never merges.
#
# Required env (Actions defaults usually supply them):
#   GITHUB_TOKEN / FORGEJO_TOKEN
#   GITHUB_API_URL          e.g. https://forgejo.lan/api/v1
#   GITHUB_REPOSITORY       owner/repo
#
# Optional:
#   UPSTREAM_REMOTE / UPSTREAM_REF / UPSTREAM_URL — same as upstream-status.sh
#   ISSUE_TITLE_PREFIX      default: Upstream ahead:
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="${GITHUB_WORKSPACE:-$(cd "$SCRIPT_DIR/.." && pwd)}"
cd "$ROOT"

token="${GITHUB_TOKEN:-${FORGEJO_TOKEN:-}}"
api="${GITHUB_API_URL:-}"
repo="${GITHUB_REPOSITORY:-}"
prefix="${ISSUE_TITLE_PREFIX:-Upstream ahead:}"

if [[ -z "$token" || -z "$api" || -z "$repo" ]]; then
  echo "Missing GITHUB_TOKEN/FORGEJO_TOKEN, GITHUB_API_URL, or GITHUB_REPOSITORY" >&2
  exit 1
fi
api="${api%/}"

upstream_remote="${UPSTREAM_REMOTE:-upstream}"
upstream_ref="${UPSTREAM_REF:-main}"
upstream_url="${UPSTREAM_URL:-https://github.com/danieldaeschle/rusty-teams.git}"

if ! git remote get-url "$upstream_remote" >/dev/null 2>&1; then
  git remote add "$upstream_remote" "$upstream_url"
fi
git fetch --quiet "$upstream_remote" "$upstream_ref"
upstream_tip="$upstream_remote/$upstream_ref"

# Checkout is Forgejo main tip (Actions checkout of the default branch).
fork_ref="HEAD"
ahead="$(git rev-list --count "$fork_ref..$upstream_tip")"

curl_opts=( -sS )
case "$api" in
  https://forgejo.lan/*|http://forgejo.lan/*) curl_opts+=( -k ) ;;
  https://forgejo.devops-geek.net/*|http://forgejo.devops-geek.net/*) curl_opts+=( -4 ) ;;
esac

api_curl() {
  curl "${curl_opts[@]}" \
    -H "Authorization: token ${token}" \
    -H "Content-Type: application/json" \
    "$@"
}

# List open issues and find those with our title prefix (newest first).
list_open_watch_issues() {
  # Forgejo/Gitea: type=issues, state=open; filter client-side by title prefix.
  api_curl "${api}/repos/${repo}/issues?state=open&type=issues&limit=50" \
    | jq -c --arg p "$prefix" \
      '[.[] | select(.title | startswith($p))] | sort_by(.number) | reverse'
}

close_issue() {
  local number="$1"
  api_curl -X PATCH \
    -d '{"state":"closed"}' \
    "${api}/repos/${repo}/issues/${number}" >/dev/null
  echo "Closed issue #${number} (fork in sync)."
}

create_issue() {
  local title="$1"
  local body_file="$2"
  jq -n --arg title "$title" --rawfile body "$body_file" \
    '{title:$title, body:$body}' \
    | api_curl -X POST -d @- "${api}/repos/${repo}/issues" \
    | jq -r '"Created issue #\(.number): \(.html_url // .url)"'
}

update_issue() {
  local number="$1"
  local title="$2"
  local body_file="$3"
  jq -n --arg title "$title" --rawfile body "$body_file" \
    '{title:$title, body:$body}' \
    | api_curl -X PATCH -d @- "${api}/repos/${repo}/issues/${number}" \
    | jq -r '"Updated issue #\(.number): \(.html_url // .url)"'
}

if [[ "$ahead" -eq 0 ]]; then
  echo "In sync: HEAD already contains $upstream_tip"
  issues_json="$(list_open_watch_issues)"
  echo "$issues_json" | jq -r '.[].number' | while read -r num; do
    [[ -n "$num" ]] || continue
    close_issue "$num"
  done
  exit 0
fi

commit_list="$(git log --format='%ad %h %s' --date=short "$fork_ref..$upstream_tip")"
title="${prefix} ${ahead} commit(s) on danieldaeschle/main"

body_file="$(mktemp)"
trap 'rm -f "$body_file"' EXIT
cat >"$body_file" <<EOF
Upstream \`danieldaeschle/rusty-teams\` \`main\` is ahead of Forgejo \`main\` by **${ahead}** commit(s).

The Upstream watch does **not** merge. Sync consciously when ready:

\`\`\`bash
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
\`\`\`

Then close this issue (or wait for the next watch run after sync — it closes the open watch issue when in sync).

## Commits

\`\`\`
${commit_list}
\`\`\`

_Opened or updated by \`.forgejo/workflows/upstream-watch.yaml\`._
EOF

issues_json="$(list_open_watch_issues)"
count="$(echo "$issues_json" | jq 'length')"
if [[ "$count" -eq 0 ]]; then
  create_issue "$title" "$body_file"
elif [[ "$count" -eq 1 ]]; then
  number="$(echo "$issues_json" | jq -r '.[0].number')"
  update_issue "$number" "$title" "$body_file"
else
  # Prefer a single issue: update newest, leave a note about extras.
  number="$(echo "$issues_json" | jq -r '.[0].number')"
  extras="$(echo "$issues_json" | jq -r '.[1:] | map("#\(.number)") | join(", ")')"
  echo "" >>"$body_file"
  echo "_Note: other open watch issues still exist (${extras}); close them manually._" >>"$body_file"
  update_issue "$number" "$title" "$body_file"
fi
