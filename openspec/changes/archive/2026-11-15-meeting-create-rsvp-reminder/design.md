# Design

## Approach

Close the three Partial roadmap rows by verifying the existing create / RSVP / reminder stack live, tightening the OpenSpec for Upcoming RSVP and optional push, and only wiring a Teams reminder push when research proves the event.

## Existing code

- Create: `crates/chatsvc/src/calendar/schedule.rs` (`create_event`, `create_event_with_join`), `crates/app-state/src/call/meeting_create.rs`, Calls tab / calendar «New meeting» UI.
- RSVP: Graph `accept` / `tentativelyAccept` / `decline` in `schedule.rs`; Google attendee patch; peek and Upcoming menus in app views.
- Reminder poll: `crates/chatsvc/src/calendar/reminders.rs` (`reminderView`, snooze, dismiss); toast wiring in notify center / Linux desktop notifications.

## Live smoke

Use the owner account only. Create short test meetings, exercise RSVP, wait for or force a Soon toast (Join, Snooze, dismiss). Delete test meetings afterwards (`GUARDRAILS.md`). Record pass/fail; ship bugfixes on Forgejo `main` before flipping Roadmap Done.

## Event 128 research

Roadmap mentions «push event 128» without a research note. Search Teams web captures / bundles and existing `docs/research/` for the channel and payload. Write `docs/research/meeting-reminder-push.md` (or extend an existing calendar note) and add a row to `docs/research/internal-endpoints.md` when it is not Graph.

If proven: parse the push, call the same reminder apply path as the poll, add a unit test on the parser, keep the poll as fallback.

If not proven: document the negative finding; leave Meeting start reminder Partial; do not invent a handler.

## Delivery

- Everyday commits to `origin` (Forgejo).
- Upstream PR `pr/meeting-reminders` only if this change lands code beyond Roadmap/docs/OpenSpec.
- Archive this OpenSpec change after merge on the fork.
