# Tasks

## 1. OpenSpec

- [x] 1.1 Proposal, design, and capability deltas for macos-sign-in, screen-share, tray-menu, macos-desktop-notifications
- [x] 1.2 Validate change: `openspec validate macos-prod-foundation`
- [x] 1.3 Archive into baseline specs after merge on Forgejo `main`

## 2. Sign-in and share

- [x] 2.1 Cherry-pick upstream #45 Chromium forks + version major; update `openspec/specs/macos-sign-in`
- [x] 2.2 Cherry-pick upstream #47 ScreenCaptureKit picker keep-alive; unit test `frames_report_the_macos_picker_outcome`
- [x] 2.3 Managed-browser kill match for Edge/Brave/Helium/Vivaldi

## 3. Desktop integration

- [x] 3.1 Shared `tray-icon` tray on macOS; close-to-tray via main_window reopen
- [x] 3.2 Notification Center client + NotificationCenter desktop path on macOS; ADR 0017
- [x] 3.3 ROADMAP / README honesty for tray, update, notifications

## 4. CI and packaging

- [x] 4.1 Forgejo `macos-arm64` test job
- [x] 4.2 `docs/macos-smoke.md` live checklist
- [x] 4.3 Optional codesign/notarize + bare Mach-O self-update asset; release `v0.4.0-joe.6`
