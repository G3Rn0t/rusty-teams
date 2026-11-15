# Tasks

## 1. Spec and decision

- [x] 1.1 OpenSpec proposal, design, and `linux-desktop-notifications` spec; Verify: `openspec validate linux-desktop-notifications`
- [x] 1.2 ADR 0015 for freedesktop Notifications on Linux; Verify: file under `docs/decisions/` and row in `docs/decisions/README.md`

## 2. Payload builder

- [x] 2.1 Pure desktop notification payload from toast / ring / meeting models (title, body, actions, timeout, urgency, replace key); Verify: unit tests for preview off, mention timeout, urgent urgency, ring no timeout, meeting Soon vs Live, bundling key
- [x] 2.2 Locale keys for notification actions (EN/DE); Verify: `tr("notify.*")` resolves in both locales

## 3. Linux D-Bus client

- [x] 3.1 zbus Notifications client: Notify with replace, CloseNotification, ActionInvoked, NotificationReplied, GetCapabilities, suppress-sound, optional image-data; Verify: builds on Linux; unit-testable mapping of events without a live bus where isolable
- [x] 3.2 `system_quiet` reads `Inhibited` when present; Verify: unit or stub test for missing property → false
- [x] 3.3 Missing daemon: log once per session, no panic; Verify: client returns empty / error path covered by test or documented smoke

## 4. Wire NotificationCenter

- [x] 4.1 On Linux, publish visible stack and call toasts through the client instead of GPUI popups; CloseNotification only on dismiss / open / ring gone; Verify: `cargo test` focused notify + `cargo check -p app`
- [x] 4.2 Dispatch activation, mark read, reply, ring accept/decline, meeting join/snooze/dismiss; Verify: action ids map to existing center methods; compile on Linux

## 5. Roadmap and smoke

- [x] 5.1 ROADMAP: Notifications on Linux → Done; drop Next item for desktop toasts on Linux; Verify: ROADMAP lines updated
- [x] 5.2 Plasma smoke checklist recorded in the change tasks or design (message, mention, preview off, reply, mark read, replace, ring decline, meeting join, DND, no double sound); Verify: checklist present for manual run

### Plasma smoke (manual)

1. Message toast appears with sender and preview; app tone plays once (no shell double beep).
2. Mention lasts longer; Mark as read clears unread and closes the notification.
3. Preview off shows «New message» only.
4. Second message in the same chat replaces the first notification.
5. Reply: inline when Plasma offers it, otherwise opens the chat; Activate opens the chat at the message.
6. Incoming ring: Decline closes; Audio / Video accept as offered; no auto-timeout.
7. Meeting Soon: Snooze + Join; Live replaces the same entry with Join.
8. Desktop Do not disturb / inhibited suppresses ordinary toasts.
9. Without a notification daemon: no extra window, sound still plays, one warning in the log.

## Workflow follow-up

- Archive change after merge (`/opsx-archive`)
- Optional Upstream PR: thin Linux notifications slice only if desired
