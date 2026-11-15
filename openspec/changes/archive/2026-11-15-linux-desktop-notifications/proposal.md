# Proposal

## Why

On Linux the app already decides when a toast should appear and plays the Teams notification and ring sounds, but the corner card never shows. The Windows path paints a GPUI popup with Win32 topmost placement; those native hooks are stubs on Linux, so message, ring, and meeting toasts stay silent visually. Wayland also cannot host a borderless always-on-top inactive GPUI popup the way Windows does.

## What Changes

- On Linux, desktop toasts use `org.freedesktop.Notifications` (session bus) instead of GPUI popup windows.
- Same show/hide rules as today (`decide`, mute, Do not disturb, foreground chat, mute-in-calls, urgent through DND).
- Same user actions as the Windows card: open chat, mark as read, reply (inline when the shell supports it), decline / accept audio / accept video on rings, join / snooze / dismiss on meeting reminders.
- App keeps playing its own notification and ring tones; the shell sound is suppressed.
- Desktop Do not disturb (`Inhibited` when the daemon exposes it) feeds `system_quiet`, matching Focus Assist on Windows.
- Notifications may remain in the desktop notification history after the popup times out (Plasma). Closing on our fade timer is not forced.
- Sender avatar is attached as `image-data` when available; otherwise the app icon.
- When no notification daemon is present: log once, keep sounds, no dead extra window.
- macOS stays on the current stub. Windows keeps the GPUI card.

## Capabilities

### New Capabilities

- `linux-desktop-notifications`: Desktop notification presentation on Linux for chat, rings, meeting reminders, and agent toasts via the freedesktop Notifications API.

### Modified Capabilities

- (none)

## Impact

- `NotificationCenter` Linux display path (no GPUI toast popups).
- New Linux D-Bus client next to the existing StatusNotifier tray.
- Payload builder + unit tests without a bus.
- Locale strings for notification actions (EN/DE).
- ADR for OS-native toasts vs GPUI copy.
- ROADMAP: Notifications on Linux → Done.
