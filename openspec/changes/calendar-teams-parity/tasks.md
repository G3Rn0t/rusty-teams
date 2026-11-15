# Tasks

## 1. Reliable grid load (calendar-accounts)

- [x] 1.1 Load the grid's Outlook range through the core session (`Calendar::new(engine.remote().session())`) instead of `CallLauncher::calendar_view`. Set a pending flag when no engine exists yet and run the load on `BackendEvent::Engine`. Verify: unit test in `crates/app-state` that a load requested before the engine runs once the engine arrives.
- [x] 1.2 Reload the visible range on each agenda poll result while the calendar section is shown. Verify: unit test that `BackendEvent::Calendar` triggers a grid reload only with the calendar open.
- [x] 1.3 Track per-source failures on `CalendarWeek` (set per load, cleared on success). Render a loading indicator and an inline notice with Retry under the calendar header. Drop the once-per-session Google toast for the grid path. Verify: unit test for failure state transitions, plus a demo-mode check of the notice.
- [x] 1.4 Add `store::merge_google_tokens` (re-read accounts, copy tokens and refreshed calendar lists only). Use it in the grid load and in `calendar_loop`. Verify: `cargo test -p store` test that a toggle saved during a fetch survives the merge.
- [x] 1.5 Record a diagnostics line per grid load: range, events per source, duration, failures. Verify: unit test of the line formatter.

## 2. Calendar preferences and mailbox working hours (calendar-view-settings)

- [x] 2.1 Add `calendar_prefs` to `crates/app-call-model`: default view, last span, first-day override, time scale, weekend rule, pane hidden, collapsed groups, cached work hours. Load and save as JSON under meta `calendar.prefs` with per-field defaults. Verify: `cargo test -p app-call-model calendar_prefs` (round trip, broken JSON, defaults).
- [x] 2.2 Derive the regional first day of week in `app_base::format` from the regional locale. Verify: `cargo test -p app-base` for en-US (Sunday), de-CH (Monday), ar-SA (Saturday).
- [x] 2.3 Add `crates/graph/src/mailbox.rs` with working hours read (`GET /me/mailboxSettings`) and write (`PATCH workingHours`, time zone sent back unchanged) using scope `MailboxSettings.ReadWrite`. Parse days, start, end and time zone. Verify: `cargo test -p graph mailbox` with captured response shapes.
- [x] 2.4 Load the working hours into `AppState` at engine ready and cache them in prefs. Add the `set_work_hours` action with revert and notice on failure. Verify: unit test of revert on a failed save.
- [x] 2.5 Parameterise `week_grid` by prefs:
  - `visible_dates(span, anchor, prefs)`;
  - `week_start(date, first_day)`;
  - Work week from work days, weekend rule;
  - month grid start from the first day;
  - `week_days` over a date list.
  Update the callers (`week.rs`, demo week). Verify: `cargo test -p app-call-model week_grid` with new cases (Sunday start, Saturday start, non-consecutive work days, this/next week on Sunday, month header order).
- [x] 2.6 Persist the span: initial span from the default view, and `set_calendar_span` writes the last span. Day opened from a month cell does not write it. Verify: unit test in `crates/app-state` for restart semantics through the store.
- [x] 2.7 Settings › Calendar: add a View section with selects for:
  - default view;
  - first day (Regional, Monday, Sunday, Saturday);
  - work days (chips);
  - work start and end (30-minute steps);
  - time scale;
  - weekend rule.
  Add localized search terms in `settings/nav.rs` and include Calendar in the search-term test. Verify: `cargo test -p app settings` and a layout_guard select-alignment test for one new select.
- [x] 2.8 Write decision note `docs/decisions/0016-calendar-week-start-and-time-scale-stay-local.md` and list it in `docs/decisions/README.md`. Verify: file present and linked.

## 3. Scroll to work start (calendar-now-view)

- [x] 3.1 Add a work-start scroll offset helper in `calendar_now` (work start minus 30 minutes, clamped, hour height as a parameter). Generalise the scroll request so open, span change, navigation and date pick align to now when today is visible, otherwise to work start. Verify: `cargo test -p app-call-model calendar_now` plus a state test that `shift_calendar_week` requests alignment.

## 4. Grid look and strings (calendar-grid-layout)

- [x] 4.1 Add `theme::calendar_color(index)` (accent, then avatar palette) and the colour row in `docs/design/islands/SPEC.md`. Map events to calendar indexes by source and calendar id. Verify: `cargo test -p app-base theme` wrap-around test and a mapping unit test.
- [x] 4.2 Add localized weekday names in `app_base::format` (full, short, letter; de and en). Use them in day headers, the month header and the mini month. Verify: `cargo test -p app-base format`.
- [x] 4.3 Day headers: number plus full weekday name, today in the accent colour with the bar. Verify: demo-mode visual check against the Teams screenshot.
- [x] 4.4 Hour grid geometry from the time scale:
  - hour lines and lighter minor lines (solid, islands look);
  - hour labels at the top of the line, 12h/24h from the regional clock;
  - work-hour and non-work-day shading.
  Verify: unit tests for row height and label text, plus a demo check of 15/30/60.
- [x] 4.5 Now line: thin and light across all visible days, thicker accent line with a dot in today's column. Verify: demo check in Week.
- [x] 4.6 Event blocks: bold title with the organizer on the same line, more title lines for tall blocks, series icon, block and chip colours from the calendar colour. Join and the source label stay. Apply the colours to all-day and month chips. Verify: demo check, plus the existing week-grid tests stay green.
- [x] 4.7 Header: pane toggle (state in prefs), "Calendar" title moved to the pane, view menu with a localized span label. Verify: layout_guard header checks at 640/1280/1920 px.
- [x] 4.8 Localize all strings in `calendar_view.rs`, `calendar_month.rs`, `calendar_date_picker.rs` and `week_grid` labels through `tr()`, with new `calendar.view.*` keys (en + de) in `app.yml`. Verify: `cargo test -p app i18n` (every key has en and de) and a German demo check.

## 5. Calendar list pane (calendar-sidebar)

- [x] 5.1 Extract the mini month into `views/calendar_mini_month.rs` and use it in the popover and the pane. It marks the visible range, follows navigation until moved by the user, and navigates on click. Verify: unit test of the visible-range marking, plus a demo check.
- [x] 5.2 Rebuild the pane:
  - "Calendar" heading;
  - mini month;
  - Add calendar opening Settings › Calendar;
  - "My calendars" and per-account groups with chevron collapse (persisted);
  - group check box with a `set_google_account_selected` action;
  - colour check boxes;
  - Show all above five calendars.
  Verify: unit tests for the group check state and the Show all filter, plus a layout_guard pane check.

## 6. Integration

- [x] 6.1 Run the full checks: `cargo fmt --check`, `cargo clippy --workspace --all-targets -- -D warnings`, `cargo test -p app-call-model -p app-state -p graph -p store -p app-base`, `cargo test -p app layout_guard`.
- [x] 6.2 Live check against the own account, with the same week in Teams web and the app in Week view:
  - the 16–20 November events appear;
  - work hours match the mailbox;
  - the diagnostics line shows the counts.
  Restore any changed mailbox setting afterwards.
- [x] 6.3 Update `ROADMAP.md` calendar rows.

## Workflow follow-up

- After merge on the fork: archive the change (`openspec archive calendar-teams-parity`).
