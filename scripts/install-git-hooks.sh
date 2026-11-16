#!/bin/sh
# Installiert den Fork-Push-Hook für alle Worktrees dieses Klons.
# Aufruf: scripts/install-git-hooks.sh
# Der Hook liegt versioniert in .githooks/pre-push. Git führt Hooks in
# verknüpften Worktrees nur aus, wenn core.hooksPath auf ein gemeinsames
# Verzeichnis zeigt. Die Kopie überlebt einen Checkout ohne .githooks/.
set -eu

cd "$(git rev-parse --show-toplevel)"
common=$(git rev-parse --path-format=absolute --git-common-dir)
mkdir -p "$common/hooks"
cp .githooks/pre-push "$common/hooks/fork-push-guard.sh"
chmod 755 "$common/hooks/fork-push-guard.sh"

cat > "$common/hooks/pre-push" <<'EOF'
#!/bin/sh
# Wrapper von scripts/install-git-hooks.sh. Bevorzugt die versionierte Datei
# im aktuellen Checkout, sonst die zuletzt installierte Kopie.
set -eu
root=$(git rev-parse --show-toplevel 2>/dev/null || true)
if [ -n "$root" ] && [ -f "$root/.githooks/pre-push" ]; then
  exec /bin/sh "$root/.githooks/pre-push" "$@"
fi
here=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
exec /bin/sh "$here/fork-push-guard.sh" "$@"
EOF
chmod 755 "$common/hooks/pre-push"
git config core.hooksPath "$common/hooks"
printf 'hooksPath=%s\n' "$(git config --get core.hooksPath)"
