#!/usr/bin/env bash
# Build dist/rusty-teams-<ver>-x86_64.flatpak from the SDK manifest (no host binary wrap).
# Intended entry point for Forgejo Release (Linux) job `flatpak` on ubuntu-latest:
# installs Flathub Platform/SDK on the runner, builds inside the SDK, bundles the .flatpak.
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
GENERATOR="${FLATPAK_CARGO_GENERATOR:-$FLATPAK_DIR/flatpak-cargo-generator.py}"
GENERATED="$FLATPAK_DIR/generated-sources.json"
WORKDIR="$FLATPAK_DIR/.flatpak-build"
REPO="$FLATPAK_DIR/.flatpak-repo"
CACHE="$FLATPAK_DIR/.flatpak-cache"
DATE="$(date -u +%Y-%m-%d)"
EXCEPTIONS="$FLATPAK_DIR/flatpak-builder-lint-exceptions.json"

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
  python3 -m pip install --user -q "${CARGO_GEN_DEPS[@]}"
  python3 "$GENERATOR" "$ROOT/Cargo.lock" -o "$GENERATED"
fi
[[ -s "$GENERATED" ]] || {
  echo "generated-sources.json is empty" >&2
  exit 1
}

desktop-file-validate "$FLATPAK_DIR/${APP_ID}.desktop"

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
  --env=FLATPAK_APP_VERSION="$VERSION"
  --env=FLATPAK_APP_DATE="$DATE"
)

# Bake Google OAuth client into the binary when CI provides it (never commit secrets).
if [[ -n "${TEAMS_GOOGLE_CLIENT_ID:-}" ]]; then
  BUILDER_ARGS+=(--env=TEAMS_GOOGLE_CLIENT_ID="$TEAMS_GOOGLE_CLIENT_ID")
fi
if [[ -n "${TEAMS_GOOGLE_CLIENT_SECRET:-}" ]]; then
  BUILDER_ARGS+=(--env=TEAMS_GOOGLE_CLIENT_SECRET="$TEAMS_GOOGLE_CLIENT_SECRET")
fi

echo "flatpak-builder (SDK build)…"
(
  cd "$FLATPAK_DIR"
  flatpak-builder "${BUILDER_ARGS[@]}" "$WORKDIR" "$(basename "$MANIFEST")"
)

if command -v flatpak-builder-lint >/dev/null 2>&1; then
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
