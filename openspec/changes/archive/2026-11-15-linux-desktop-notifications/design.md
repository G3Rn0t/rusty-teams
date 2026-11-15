# Design

## Context

Toast *policy* already lives in `decide` / `ToastStack`. Windows only adds a surface: a GPUI `WindowKind::PopUp` placed with Win32. Linux stubs `native_handle`, `place`, and `prepare_toast_window`, so `open_popup` cannot produce a usable corner card. ADR 0004 and Guardrails allow OS-native toasts when the user path matches Teams.

## Goals / Non-Goals

**Goals**

- Visible Linux toasts for messages, rings, meeting reminders, and agent toasts.
- Same actions and timeouts as the Windows card where the protocol allows.
- One decision path for “show or not”; only the surface changes.
- No double sound.

**Non-Goals**

- Pixel-identical Teams / Windows GPUI card on Wayland.
- macOS notifications in this change.
- Taskbar badge / urgent flash (separate Windows APIs; tray mention dot already exists on Linux).

## Decisions

1. **Surface = freedesktop Notifications**, not a GPUI popup. Wayland cannot reliably host the Windows-style card.
2. **Stack stays SoT.** `sync` publishes the visible stack + call toasts; replace id per stable key (conversation / ring / meeting).
3. **CloseNotification only on user/app dismiss** (mark read, open, hide all, ring gone, meeting action). Timer expiry leaves the entry for the shell history.
4. **suppress-sound** hint; app plays `linux_sound` as today.
5. **system_quiet** reads `Inhibited` when present; otherwise false.
6. **zbus** directly (no notify-rust) so hints, capabilities, and `NotificationReplied` stay explicit.
7. **Inline reply** when capability `inline-reply` is advertised; otherwise Reply activates the chat.

## Risks / Trade-offs

- [GNOME history] → entries often vanish with the timeout; Plasma keeps them. Acceptable OS difference.
- [No daemon] → log once; sounds still work.
- [Activation under focus stealing] → reuse `raise_main_window` / `activate_window` as tray already does.
- [Avatar race] → first notify without image, replace when avatar bytes arrive.

## Migration

None. Existing Windows path unchanged. Linux users gain toasts on next release build.

## Plasma smoke (manual)

1. Message toast with preview; single app tone (no shell double sound).
2. Mention, Mark as read, preview off, replace on second message in the same chat.
3. Reply (inline or open chat), Activate opens the chat at the message.
4. Ring: Decline / Audio / Video; no timeout.
5. Meeting Soon (Snooze + Join) → Live replace.
6. Desktop Do not disturb suppresses ordinary toasts.
7. No daemon: no popup window, sound still plays, one log warning.
