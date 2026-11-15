## 1. Agent rule

- [x] 1.1 Land `.cursor/rules/openspec-first.mdc` (`alwaysApply`) and the OpenSpec-first paragraph in `AGENTS.md` on Forgejo `main`.
- [x] 1.2 Verify: `openspec validate meeting-create-rsvp-reminder` passes.

## 2. Research reminder push

- [x] 2.1 Search Teams web bundles / captures and repo docs for «event 128» / meeting reminder push (channel, payload).
- [x] 2.2 Write findings under `docs/research/` and update `docs/research/internal-endpoints.md` when the path is not Graph.
- [x] 2.3 Decide: wire push to the existing toast path, or keep poll-only and leave Reminder Partial with the research note.

## 3. Live smoke

- [ ] 3.1 Outlook home: New meeting → appears in grid; delete after.
- [ ] 3.2 Outlook invitation: Accept and Decline from Upcoming (and peek once); delete / restore as needed.
- [ ] 3.3 Reminder toast: Soon Join / Snooze / dismiss on an own Outlook meeting; cleanup.
- [ ] 3.4 When Google is connected: create with a Google write target and one Google RSVP patch; cleanup.
- [x] 3.5 Automated verify: `cargo test -p chatsvc --lib -- schedule reminders` and `cargo test -p app-state --lib -- reminder rsvp schedule` (2026-11-15, all green). GUI live smoke still open (no computer-use in this session).

## 4. Optional push wiring

- [x] 4.1 Skipped: research did not prove event 128; no push parser.
- [x] 4.2 Skipped with 4.1.
- [x] 4.3 Keep `reminderView` polling as SoT (unchanged).

## 5. Roadmap and archive

- [x] 5.1 Schedule / Answer stay Partial until GUI live smoke; notes updated with unit-test date.
- [x] 5.2 Reminder stays Partial; research reference in Roadmap and `docs/research/meeting-reminder-push.md`.
- [x] 5.3 `/opsx-archive` for `meeting-create-rsvp-reminder` (2026-11-15; GUI smoke tasks left open on purpose).
