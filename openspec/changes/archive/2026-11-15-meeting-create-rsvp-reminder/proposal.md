# Proposal

## Why

Roadmap still marks Schedule a meeting, Answer meeting invitations, and Meeting start reminder as Partial. The create, RSVP, and reminder paths already exist; what is missing is a live smoke against a real account, explicit Upcoming-list RSVP behaviour in the baseline, and a decision on whether Teams push «event 128» should drive reminders instead of (or beside) `reminderView` polling.

## What Changes

- Confirm New meeting create for Outlook home and Google write targets with a live smoke; fix bugs found; mark Schedule a meeting Done when green.
- Confirm RSVP from Upcoming (and peek) for Outlook Graph accept/tentative/decline and Google `responseStatus`; mark Answer meeting invitations Done when green.
- Document Upcoming RSVP as a required surface (not only the event peek).
- Research Teams push event 128; if proven, feed the same reminder toast path as the poll (no second toast behaviour). If not proven, keep Partial with a research note and leave the poll as SoT.
- Out of scope: Calendar view layout (already Done), Google Connect OAuth UX, Pre-join screen, second-person live calls.

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `calendar-accounts`: Upcoming-list RSVP; optional Teams reminder push that shares the existing toast path when the event is proven.

## Impact

- Live smoke with the owner's account (own meetings only; delete after).
- Possible fixes in `crates/chatsvc/src/calendar/schedule.rs`, `reminders.rs`, `crates/app-state/src/call/meeting_create.rs`, Upcoming/RSVP UI.
- Research under `docs/research/` and `docs/research/internal-endpoints.md` when the push is not Graph.
- Roadmap parity counters for the two Done rows when smoke passes.
