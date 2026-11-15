# Design

## Context

macOS already shared Linux’s managed Chromium + CDP session and routed share through libwebrtc ScreenCaptureKit with `allow_sck_system_picker`. The portal capture thread assumed a Wayland-style delegated picker controller; on macOS that is absent, so the app dropped the capturer immediately. Sign-in only searched Chrome/Chromium. Tray and desktop toasts were stubs (`Tray::new` → `None`; GPUI-only cards).

## Goals / Non-Goals

- Goals: unblock daily-driver sign-in and share; tray + Notification Center parity with Linux policy; CI test job; packaging hooks for signed builds and self-update.
- Non-Goals: guest multi-org (#46); Sparkle; full Notification Center action parity with freedesktop; replacing managed Chromium with a native WebView.

## Decisions

1. **Chromium forks for managed session** — Same CDP profile model; discover apps under `/Applications` and `~/Applications` in a fixed preference order. User-agent major = highest dotted major in `--version` so Helium-style lines work.
2. **Screen share without delegated picker** — Keep capturer; poll frames; first frame = selected; permanent error before frames = cancelled. Wayland delegated path unchanged.
3. **Tray** — Reuse Windows `tray-icon` implementation for macOS; close-to-tray uses `main_window` close/reopen (no reliable AppKit hide through current stubs).
4. **Toasts** — Same `DesktopNotifications` policy as Linux; macOS backend via `notify-rust`. Actions best-effort. ADR 0017.
5. **Self-update** — Publish bare fat Mach-O `*-macos-universal` beside the `.app` zip; allow update only when running from a `.app`.
6. **OpenSpec timing** — Behaviour shipped in `v0.4.0-joe.6`; this change is archived immediately so the baseline matches production (openspec-first catch-up).

## Risks

- Notification Center actions weaker than freedesktop; default activation is the main path.
- Unsigned local builds still need right-click / TCC prompts until notarization secrets are set on the Mac runner.
