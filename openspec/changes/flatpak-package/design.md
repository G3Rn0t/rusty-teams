# Design

## Context

See proposal.md for motivation. Today `packaging/flatpak/` stages a prebuilt `target/release/teams` into Freedesktop Platform 24.08, rewrites the desktop file with `sed`, and generates a minimal metainfo at build time. The release job treats Flatpak failure as a warning. Login still expects host Chrome on PATH; finish-args omit notifications, tray, PipeWire, and camera device access.

Build constraints that shape the approach: `vendor/webrtc-sys` requires Clang ≥ 21 against the hermetic libwebrtc libc++; Google OAuth client id is baked via `option_env!` at compile time; Linux ONNX Runtime loads `libonnxruntime.so` optionally and falls back to tract; camera uses V4L2 (`nokhwa`); screen share uses the ScreenCast portal + PipeWire through libwebrtc.

## Goals / Non-Goals

**Goals:**

- One committed manifest that builds and ships a convention-compliant Flatpak without Flatseal overrides for the documented feature set.
- App behaviour under `FLATPAK_ID` matches ADR 0014’s intent for packaged installs (no XDG self-install / GitHub self-update).
- Release CI treats Flatpak as a required Linux asset with validation.

**Non-Goals:**

- Publishing to Flathub in this change (bundle on Forgejo/GitHub releases only).
- Replacing managed Chrome with a built-in WebView or embedding Chromium sources in-tree.
- Changing window `app_id` / `StartupWMClass` away from `rusty-teams`.
- aarch64 Flatpak in this change (`only-arches: [x86_64]` for Chrome extra-data).

## Decisions

### 1. Build inside the SDK, not wrap a host binary

**Choice:** `flatpak-builder` compiles `cargo build -p app --release --frozen --offline` in the Freedesktop SDK with Rust and LLVM extensions; sources from `flatpak-cargo-generator` on `Cargo.lock` plus a `dir` source of the checkout.

**Why:** Host glibc vs runtime ABI mismatches and “best effort” staging are what made the current bundle fragile. Offline cargo sources keep builds reproducible and Flathub-ready later.

**Alternatives:** Keep prebuilt binary staging (rejected — dirty and ABI-risky); full Flathub submission now (deferred).

### 2. Runtime / SDK pin for Clang 21

**Choice:** Pin `org.freedesktop.Platform` / `Sdk` to the current stable branch that ships an LLVM extension meeting webrtc-sys’s Clang 21 check (verify at implement time; leave 24.08).

**Why:** Distro clang on the runner is too old for hermetic libwebrtc; Flatpak LLVM extension is the package-native equivalent of the release job’s `clang-21`.

### 3. Chrome as `extra-data` + zypak

**Choice:** Google Chrome `.deb` as Flatpak `extra-data` (URL, size, sha256). Install downloads from Google. Wrapper `/app/bin/google-chrome` runs `zypak-wrapper` on the real chrome binary. Finish-arg `--talk-name=org.freedesktop.Flatpak` only for zypak’s nested sandbox. No `--filesystem=host`, no `flatpak-spawn --host`, no `--no-sandbox`.

**Why:** Matches how other Chromium Flatpaks keep the browser sandbox; login stays inside the app sandbox with profile under Flatpak `XDG_DATA_HOME`.

**Alternatives:** Host Chrome via `--filesystem=host` (rejected — Flatseal tax); Chromium from Flathub as extension (heavier coupling).

### 4. Finish-args for product defaults

**Choice:** Network, ipc, wayland, fallback-x11, dri, pulseaudio, pipewire, `xdg-download`, Notifications talk-name, StatusNotifierWatcher talk-name, StatusNotifierItem own-name wildcard, `--device=all` for V4L2 (documented; Flatpak has no narrower camera permission for `/dev/video*`).

**Why:** Matches what the app already does on a normal desktop session so the user does not open Flatseal.

### 5. Gate install/update on `FLATPAK_ID`

**Choice:** Treat non-empty `FLATPAK_ID` as “packaged Flatpak”. Suppress `should_offer_install`, Settings install/replace/remove, and `self_update_allowed`. Keep GPUI `app_id` as `rusty-teams`. Resolve notification/tray desktop-entry from `FLATPAK_ID` when set, else `rusty-teams`.

**Why:** Flatpak sets `FLATPAK_ID`; ADR 0014 already says packages should not offer XDG install. Window class stays stable for existing docks.

### 6. CI: parallel Flatpak job, hard fail

**Choice:** `packages` job keeps deb/rpm/arch; new `flatpak` job builds, runs `appstreamcli validate`, `desktop-file-validate`, and `flatpak-builder-lint` (exceptions only for `--device=all` and zypak bus name); `publish` needs both. No `|| true`.

**Why:** Best-effort packaging hid broken Flatpaks from releases.

### 7. Secrets and AppStream version (Jammy builder)

**Choice:** Ubuntu 22.04 ships `flatpak-builder` 1.2.x without `--env`. Rewrite AppStream `<release>` on the host before the build. When CI sets `TEAMS_GOOGLE_CLIENT_ID` / secret, inject them into a temporary manifest copy under `build-options.env` for `option_env!` only. Never commit secrets or the runtime manifest (`.ci-manifest.yml`).

**Git file protocol:** Before `flatpak-builder`, set `protocol.file.allow=always` via process-local `GIT_CONFIG_*` so zypak's `nickle` submodule can clone from the builder's local git cache (Git ≥ 2.38 otherwise fails with `transport 'file' not allowed`).

**Host strip tools:** The Flatpak CI job installs `elfutils` so `eu-strip` exists when flatpak-builder strips zypak binaries into `/app/lib/debug`.

**AppStream compose:** The manifest sets `appstream-compose: false`. Jammy `flatpak-builder` 1.2 runs `appstream-compose` under bwrap; on act/Docker runners that fails with `execvp … No such file or directory` even when `appstream-util` is on the host. Metainfo is still installed into the app; `build_flatpak.sh` validates it with host `appstreamcli` before the build. Single-file `.flatpak` bundles do not need the OSTree AppStream branch that compose would write.

**Builder host vs finish-args:** Jammy archive `flatpak` 1.12 rejects `--socket=pipewire`. The Flatpak CI job installs `ppa:flatpak/stable` (flatpak ≥ 1.18, flatpak-builder ≥ 1.4) so Runtime 25.08 finish-args including PipeWire export cleanly. Retries skip permanent finish/tooling errors. Nested `org.flatpak.Builder` was tried and rejected: act/Docker has no D-Bus for `flatpak run`.

## Risks / Trade-offs

- [Clang/runtime mismatch] → Pin SDK + LLVM extension after a smoke `flatpak-builder` and document the exact versions in the manifest comment.
- [`ss` missing in runtime for debug-port cleanup] → Probe during first SDK build; add a small `iproute2` module into `/app` if needed so browser kill logic stays unchanged.
- [`--device=all` is broad] → Required for V4L2; document in metainfo/README and allow only that lint exception.
- [Chrome extra-data download at install] → Same pattern as other Flatpaks; document that first install needs network to Google.
- [ONNX `libonnxruntime.so` absent] → Existing tract fallback; no Flatpak-specific change required.

## Migration Plan

1. Land OpenSpec + code + packaging on Forgejo.
2. Next `v*` tag builds the new Flatpak; old best-effort assets stop appearing.
3. Users on the previous wrap-binary Flatpak uninstall and install the new bundle (or wait for the next release asset). No data migration: Flatpak `XDG_DATA_HOME` is already per-app-id.

## Open Questions

None that block specs or tasks. Exact Freedesktop branch and LLVM extension id are confirmed during the first SDK build and recorded in the manifest.
