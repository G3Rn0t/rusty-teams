# Proposal

## Why

macOS was close to the Linux managed-browser path but blocked daily-driver use: ScreenCaptureKit share flashed open and died, sign-in required Google Chrome, there was no menu-bar tray or Notification Center path, and packaging had no signing/self-update story. ROADMAP marked some of that Done while behaviour was wrong or missing.

## What Changes

- macOS managed sign-in accepts Chromium browsers (Chrome, Chromium, Edge, Brave, Helium, Vivaldi) with correct Chromium major from fork `--version` lines (upstream #45).
- Screen share keeps the ScreenCaptureKit capturer alive until the user selects or cancels; no false portal-unavailable notice (upstream #47).
- Menu-bar tray via the shared `tray-icon` path (same presence menu as Windows/Linux); close to tray reopens like Linux.
- Desktop toasts on macOS use Notification Center (`notify-rust`), same show/hide policy as Linux (ADR 0017).
- Forgejo `macos-arm64` tests; live checklist `docs/macos-smoke.md`.
- Optional codesign/notarize in `scripts/build-macos.sh`; bare `*-macos-universal` Mach-O for self-update from a `.app`.

## Capabilities

### New Capabilities

- `macos-desktop-notifications`: Notification Center presentation for chat, rings, meeting reminders, and agent toasts on macOS.

### Modified Capabilities

- `macos-sign-in`: Chromium-fork discovery and version parsing.
- `screen-share`: macOS picker must stay open until select/cancel; capturer must not be dropped for lack of a delegated picker.
- `tray-menu`: Tray host on macOS; close-to-tray reopen path.

## Impact

- `crates/browser`, `crates/calling/src/screen.rs`, `crates/app-base` tray/notify/updater/release_feed, `crates/app` notification center.
- OpenSpec baseline + ADR 0017.
- Release `v0.4.0-joe.6` (code landed; this change archives the specs).
