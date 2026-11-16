# Proposal

## Why

The current Flatpak wraps a host-built binary, leaves Chrome outside the sandbox, and asks the release job to continue when packaging fails. Users must open Flatseal for camera, tray, or browser access. A Freedesktop-conformant Flatpak with defaults that match what the app needs removes that setup and makes the Linux release asset a first-class package.

## What Changes

- Ship a committed Flatpak manifest that builds the app inside the Freedesktop SDK (Rust + LLVM extensions), with AppStream metainfo, a desktop file, and icons that match Flatpak conventions.
- Bundle Google Chrome as Flatpak `extra-data` and launch it through zypak so Microsoft sign-in works inside the sandbox without host filesystem access or Flatseal overrides.
- Set finish-args for network, Wayland/X11, PulseAudio, PipeWire (`--filesystem=xdg-run/pipewire-0`), DRI, V4L2 (`--device=all`), notifications, StatusNotifier tray, and XDG Downloads so calls, screen share, toasts, tray, and file reveal work with the published defaults.
- When `FLATPAK_ID` is set, suppress the XDG self-install offer and GitHub self-update; use the Flatpak app id for notification and tray desktop-entry hints.
- Split the Linux release workflow so Flatpak builds in its own job, validates with AppStream/desktop/lint checks, and fails the release if packaging fails (no best-effort skip).

## Capabilities

### New Capabilities

- `linux-flatpak`: Behaviour when the app runs inside Flatpak — no self-install or GitHub self-update, desktop-entry identity matches the Flatpak app id, and managed sign-in Chrome is available on the sandbox PATH.

### Modified Capabilities

- `linux-sign-in`: On Flatpak, the managed browser search MUST find the packaged `google-chrome` wrapper without requiring host PATH or filesystem overrides.

## Impact

- Packaging: `packaging/flatpak/` (manifest, desktop, metainfo, build script, Chrome wrapper, cargo sources).
- App: Linux install/update gating and desktop-entry hints under `FLATPAK_ID` (`crates/app-base`, `crates/app`).
- CI: `.forgejo/workflows/release-linux.yaml`; docs in `GITHUB_RELEASE.md` and `README.md`.
- Runtime: Freedesktop Platform/SDK, zypak, Chrome extra-data; Google OAuth client id remains a CI build env, never in the committed manifest.
