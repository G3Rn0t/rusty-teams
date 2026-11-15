# Meeting reminder push («event 128»)

Date: 2026-11-15

## Question

Roadmap Meeting start reminder says reminders are driven by the calendar / Graph `reminderView` poll and that «push event 128» is not wired. What is event 128, and should the fork subscribe to it?

## Findings

- Reminder SoT in the fork today is Graph `GET /me/reminderView` plus local Soon/Started/Live phases for non-Outlook sources (`crates/chatsvc/src/calendar/reminders.rs`, `crates/app-state/src/call/outlook_reminders.rs`, `crates/app-state/src/call/reminder.rs`).
- The chatsvc realtime layer (`crates/chatsvc/src/realtime/event.rs`) classifies Trouter messaging into `EventKind` values: NewMessage, MessageUpdate, ThreadUpdate, Typing, ReadReceipt, PinsChanged, ThreadActivity, Control, Other. There is **no** calendar-reminder kind and no handling of a numeric type `128`.
- A repo-wide search of `docs/research/`, `crates/`, and OpenSpec archives finds **no** capture, bundle excerpt, or endpoint table that defines Teams push event 128 (channel, resource type, or payload). The only mentions are the Roadmap sentence and prior agent notes quoting it.
- Older Roadmap wording said «the realtime layer does not receive it»; that matches the current `EventKind` surface, but does not prove what the Teams client sends.

## Decision

Do **not** invent a push handler. Keep polling (`reminderView` every 60 s near a meeting, plus calendar-driven phases for Google). Leave Meeting start reminder **Partial** until a live Teams web capture documents the push (or confirms Teams itself relies on ReminderView for this path).

## Follow-up

When capturing Teams web around a Soon toast: log Trouter / notification service frames, note any type or event id `128`, and update this file plus `docs/research/internal-endpoints.md` before wiring. OpenSpec `calendar-accounts` requirement «Teams reminder push shares the poll toast path» already requires proven research before code.
