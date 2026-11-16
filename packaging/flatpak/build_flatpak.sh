#!/usr/bin/env bash
# Build dist/rusty-teams-<ver>-x86_64.flatpak from the SDK manifest (no host binary wrap).
# Intended entry point for Forgejo Release (Linux) job `flatpak` on ubuntu-latest:
# installs Flathub Platform/SDK on the runner, builds inside the SDK, bundles the .flatpak.
#
# Jammy flatpak-builder 1.2.x has no --env flag. Metainfo version/date are rewritten on the
# host before the build; Google OAuth env (if set) is injected into a temporary manifest copy
# under build-options.env (never committed).
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
# shellcheck source=../common.sh
source "$ROOT/packaging/common.sh"

cd "$ROOT"

for cmd in flatpak flatpak-builder python3 curl; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Missing $cmd" >&2
    exit 1
  fi
done

VERSION="$(packaging_version "$ROOT")"
APP_ID=net.devops_geek.RustyTeams
FLATPAK_DIR="$ROOT/packaging/flatpak"
MANIFEST="$FLATPAK_DIR/${APP_ID}.yml"
RUNTIME_MANIFEST="$FLATPAK_DIR/.ci-manifest.yml"
METAINFO="$FLATPAK_DIR/${APP_ID}.metainfo.xml"
GENERATOR="${FLATPAK_CARGO_GENERATOR:-$FLATPAK_DIR/flatpak-cargo-generator.py}"
GENERATED="$FLATPAK_DIR/generated-sources.json"
WORKDIR="$FLATPAK_DIR/.flatpak-build"
REPO="$FLATPAK_DIR/.flatpak-repo"
CACHE="$FLATPAK_DIR/.flatpak-cache"
DATE="$(date -u +%Y-%m-%d)"
EXCEPTIONS="$FLATPAK_DIR/flatpak-builder-lint-exceptions.json"

cleanup() {
  rm -f "$RUNTIME_MANIFEST"
}
trap cleanup EXIT

mkdir -p "$ROOT/dist" "$CACHE"

if [[ ! -f "$GENERATOR" ]]; then
  echo "Downloading flatpak-cargo-generator.py"
  curl -fsSL \
    'https://raw.githubusercontent.com/flatpak/flatpak-builder-tools/master/cargo/flatpak-cargo-generator.py' \
    -o "$GENERATOR"
fi
chmod +x "$GENERATOR"

echo "Generating cargo sources from Cargo.lock → $GENERATED"
# Jammy apt python3-tomlkit (0.9.x) has no TOMLDocument.unwrap(); the upstream
# flatpak-cargo-generator needs tomlkit>=0.13. Prefer uv, else pip --user.
CARGO_GEN_DEPS=('aiohttp>=3.9.5,<4' 'tomlkit>=0.13.3,<1' 'PyYAML>=6.0.2,<7')
if command -v uv >/dev/null 2>&1; then
  uv run --with "${CARGO_GEN_DEPS[0]}" --with "${CARGO_GEN_DEPS[1]}" --with "${CARGO_GEN_DEPS[2]}" \
    "$GENERATOR" "$ROOT/Cargo.lock" -o "$GENERATED"
else
  # Corrupted PyPI wheels show up as hash mismatches; --no-cache-dir + retry.
  pip_ok=0
  for attempt in 1 2 3 4 5; do
    if python3 -m pip install --user --no-cache-dir -q "${CARGO_GEN_DEPS[@]}"; then
      pip_ok=1
      break
    fi
    echo "pip install failed (attempt ${attempt}/5); retrying…" >&2
    sleep $((attempt * 3))
  done
  [[ "$pip_ok" -eq 1 ]] || { echo "pip install of cargo-generator deps failed" >&2; exit 1; }
  python3 "$GENERATOR" "$ROOT/Cargo.lock" -o "$GENERATED"
fi
[[ -s "$GENERATED" ]] || {
  echo "generated-sources.json is empty" >&2
  exit 1
}

desktop-file-validate "$FLATPAK_DIR/${APP_ID}.desktop"

echo "Writing AppStream release $VERSION ($DATE) into metainfo (host, pre-builder)"
python3 - "$METAINFO" "$VERSION" "$DATE" <<'PY'
import re, sys
path, version, date = sys.argv[1:4]
text = open(path, encoding="utf-8").read()
new, n = re.subn(
    r'<release version="[^"]*" date="[^"]*"/>',
    f'<release version="{version}" date="{date}"/>',
    text,
    count=1,
)
if n != 1:
    raise SystemExit(f"expected one <release …/> placeholder in {path}, found {n}")
open(path, "w", encoding="utf-8").write(new)
PY

echo "Preparing runtime manifest (Jammy flatpak-builder has no --env)"
python3 - "$MANIFEST" "$RUNTIME_MANIFEST" <<'PY'
import os, sys
from pathlib import Path

try:
    import yaml
except ImportError as e:
    raise SystemExit("PyYAML required to inject build-options.env") from e

src, dst = Path(sys.argv[1]), Path(sys.argv[2])
doc = yaml.safe_load(src.read_text(encoding="utf-8"))
modules = doc.get("modules") or []
rusty = next((m for m in modules if isinstance(m, dict) and m.get("name") == "rusty-teams"), None)
if rusty is None:
    raise SystemExit("rusty-teams module missing from manifest")
opts = rusty.setdefault("build-options", {})
env = opts.setdefault("env", {})
for key in ("TEAMS_GOOGLE_CLIENT_ID", "TEAMS_GOOGLE_CLIENT_SECRET"):
    val = os.environ.get(key, "").strip()
    if val:
        env[key] = val
# Keep comments out; dump a clean copy for the builder only.
dst.write_text(yaml.safe_dump(doc, sort_keys=False, allow_unicode=True), encoding="utf-8")
PY

echo "Ensuring Freedesktop 25.08 SDK + rust-stable + llvm21"
flatpak remote-add --if-not-exists --user flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub \
  org.freedesktop.Platform//25.08 \
  org.freedesktop.Sdk//25.08 \
  org.freedesktop.Sdk.Extension.rust-stable//25.08 \
  org.freedesktop.Sdk.Extension.llvm21//25.08

rm -rf "$WORKDIR" "$REPO"
mkdir -p "$REPO"

BUILDER_ARGS=(
  --user
  --force-clean
  --repo="$REPO"
  --state-dir="$CACHE"
  --default-branch=stable
)

# Git ≥ 2.38 blocks file:// by default; flatpak-builder clones zypak's nickle
# submodule from its local git cache that way.
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=protocol.file.allow
export GIT_CONFIG_VALUE_0=always

echo "flatpak-builder (SDK build)…"
# crates.io / GitHub downloads occasionally die with GnuTLS recv errors; retry a few times.
attempts=3
for attempt in $(seq 1 "$attempts"); do
  if (
    cd "$FLATPAK_DIR"
    flatpak-builder "${BUILDER_ARGS[@]}" "$WORKDIR" "$(basename "$RUNTIME_MANIFEST")"
  ); then
    break
  fi
  if [[ "$attempt" -eq "$attempts" ]]; then
    echo "flatpak-builder failed after ${attempts} attempts" >&2
    exit 1
  fi
  echo "flatpak-builder failed (attempt ${attempt}/${attempts}); retrying in 30s…" >&2
  sleep 30
done

if command -v flatpak-builder-lint >/dev/null 2>&1; then
  # Lint the committed manifest (no secrets), not the runtime copy.
  if [[ -f "$EXCEPTIONS" ]]; then
    flatpak-builder-lint --exceptions "$EXCEPTIONS" manifest "$MANIFEST"
  else
    flatpak-builder-lint manifest "$MANIFEST"
  fi
fi

out="$ROOT/dist/rusty-teams-${VERSION}-x86_64.flatpak"
flatpak build-bundle "$REPO" "$out" "$APP_ID" --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo
[[ -s "$out" ]] || {
  echo "bundle missing or empty: $out" >&2
  exit 1
}
echo "Wrote $out"
