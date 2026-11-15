# Design

## Context

See proposal.md › Why. The current state that shapes the approach:

- **Span and range.** The span and range live in `CalendarWeek { start, span }` (`crates/app-state/src/call/week.rs`), in memory only. `CalendarSpan` (`crates/app-call-model/src/week_grid.rs`) hard-codes a Monday week start, a 5-day Work week and a 42-day Month.
- **Grid load.** The load (`load_calendar_week`) fetches Outlook through `CallLauncher::calendar_view`, which waits up to 30 s for the calling engine.
  - It returns silently when `call_launcher` is `None`.
  - It is not re-run when the launcher arrives.
  - `CalendarWeek.loading` is set but never rendered.
- **Agenda poll.** The agenda poll (`calendar_loop` in `crates/app-state/src/backend.rs`) uses the session directly.
- **Accounts race.** Both fetch paths load `CalendarAccounts` before the fetch and save the whole struct afterwards to persist refreshed Google tokens. That overwrites check box changes made during the fetch.
- **Mailbox access.** `GET /me/mailboxSettings` works with the `MailboxSettings.ReadWrite` scope (HTTP 200, checked live). `MailboxSettings.Read` is not granted to the Teams client. `getSchedule` (already used for the time zone) also returns `workingHours`.
- **Look rules.** Look tokens come from `docs/design/islands/SPEC.md`: palette roles only, no new hex, no new radii beyond 6/10.

## Goals / Non-Goals

**Goals:**

- Make one place, `calendar_prefs` in the call model, the source for everything that shapes the grid: span, first day, work days and hours, time scale, weekend rule.
- Make the grid load depend only on the core session.

**Non-Goals:**

- Writing first day of week or time scale to the Teams or OWA account. Teams keeps them in OWA user options, which have no Graph API. They stay local, see Decisions.
- Google calendar colours from the Google API.
- Filter menu, split buttons, time-zone settings (proposal › Out of scope).

## Decisions

1. **Preferences: one JSON meta value.** Store `CalendarPrefs` as JSON under the meta key `calendar.prefs`, following `calendar.accounts`. Unknown or broken JSON falls back to the defaults field by field (`#[serde(default)]`).
   - It holds: default view, last span, first-day override (`None` means regional), time scale, weekend rule, pane hidden, collapsed groups.
   - Alternative considered: one meta key per field, like `compose.markdown_mode`. Rejected because the settings form one record that the grid reads together.

2. **Work days and hours: the mailbox, cached locally.**
   - At engine ready and on each Settings visit, read `GET /me/mailboxSettings` (scope `MailboxSettings.ReadWrite`) into `AppState.work_hours`, and cache the result in prefs so the grid works offline and before the read finishes.
   - Writes `PATCH /me/mailboxSettings` with `{"workingHours": {daysOfWeek, startTime, endTime, timeZone}}`. The current mailbox `timeZone` is sent back unchanged.
   - The guardrail "Settings Teams knows are saved where Teams saves them" requires this.
   - Code lives in `crates/graph/src/mailbox.rs` (Graph, no internal endpoint).

3. **First day of week: regional default plus local override.**
   - The default derives from the regional locale already used for date formats (`app_base::format`):
     - Sunday for `en-us`, `en-ca`, `en-ph`, `en-au`, `en-nz`, `en-in`, `ja`, `ko`, `zh-tw`, `he`, `pt-br`;
     - Saturday for `ar` locales other than Morocco and Tunisia, and for `fa`;
     - Monday otherwise.
   - The override is local. This is a deviation from the "save where Teams saves" rule, because OWA options are not reachable through Graph. It is named in the commit body and in a decision note `docs/decisions/0016-calendar-week-start-and-time-scale-stay-local.md`.

4. **Time scale is local.** It is stored in prefs, with the same rationale as the first day.

5. **Visible dates instead of start + count.**
   - `week_grid::visible_dates(span, anchor, prefs) -> Vec<NaiveDate>` returns the dates to draw.
   - `week_days` takes that list. `week_range` takes the first date and the last date + 1.
   - Work week = the work days of the week that contains the anchor, in order from the first day of week.
   - `CalendarSpan::start_for`, `shifted` and `week_start` take the first day.
   - This replaces `span.days()` arithmetic in the view, which cannot express non-consecutive work days.

6. **Grid load uses the core session.**
   - `load_calendar_week` uses `Calendar::new(engine.remote().session())`, the same pattern as `agent_api/source.rs`. The calling launcher is no longer needed.
   - If `self.engine` is `None`, set `calendar_week.pending = true`. `BackendEvent::Engine` runs the load when that flag is set.
   - Each load records a diagnostics line with the range, the event count per source, the duration and failures. This makes an "empty week" provable.

7. **Refresh while open.** The agenda poll already runs every 5 minutes. On each `BackendEvent::Calendar`, `AppState` reloads the visible range if the calendar section is shown. This avoids a second timer. The previous events stay until the new list arrives; that is already true because the list is swapped on success only.

8. **Source errors as state, not a toast.**
   - `CalendarWeek.failed: Vec<CalendarSourceFailure { source, message }>` is set on every load and cleared on success.
   - The view renders an inline notice row under the header with a Retry button that calls `load_calendar_week`.
   - The one-shot `google_sync_notice_shown` toast is removed for the grid path.

9. **Token-only merge after a fetch.**
   - `store::merge_google_tokens(store, &fetched)` re-reads `calendar.accounts` and copies only `tokens` (and the calendar list when a refresh returned one) for matching account ids. Then it saves.
   - Both fetch paths use it instead of `save_calendar_accounts(&fetched)`.

10. **Calendar colours from palette roles.**
    - `theme::calendar_color(index)`: index 0 is `accent`, then `avatar_palette[i - 1]`.
    - The index is the position in the calendar list: Outlook first, then Google calendars in list order.
    - Events find their index by `(source, calendar_id)`.
    - `docs/design/islands/SPEC.md` › Colour gets a row "calendar colours: accent, then avatar palette".

11. **Grid geometry.** Row height per hour comes from the time scale (15 → 120 px, 30 → 96 px, 60 → 64 px, kept as named constants in the view).
    - Minor lines are dashed: short segments drawn with the existing `border` role at reduced opacity.
    - Shading uses `background` over `surface` for off-hours, painted as absolute blocks below the lines.

12. **Localized weekday names.** `format::weekday_name(weekday, WeekdayWidth::{Full, Short, Letter})` returns names from tables for de and en, keyed by the UI language (`ui_locale`). This follows Teams, which shows the UI language for names. chrono `%a`/`%A` is always English and is removed from calendar views.

13. **Left pane.**
    - The mini month is extracted from `calendar_date_picker.rs` into `views/calendar_mini_month.rs` and used by both the popover and the pane.
    - Group collapse and the "show all" expansion live in prefs (`collapsed_groups: Vec<String>`) and in view state respectively.
    - The group toggle calls a new `set_google_account_selected(account_id, on)` action.
    - Add calendar opens Settings at the Calendar section (`SettingsSection::Calendar`).

## Risks / Trade-offs

- **[Risk] The mailbox PATCH needs a scope we only verified for read.** → On 403, the setting reverts and shows a notice (spec scenario "Save fails"). The read path keeps working.
- **[Risk] Work hours are in the mailbox time zone, not the device time zone.** → Convert start and end from the mailbox `timeZone` to local time when they differ. Use the Windows → IANA map already used for `time_zone_name` if present, otherwise assume local and log it.
- **[Risk] A row height change shifts the scroll positions that `calendar_now` computes.** → Pass the hour height into `now_scroll_offset_y` and the new work-start helper. They are already parameterised.
- **[Trade-off] First day and time scale stay local, a deviation from the Teams account.** → Decision note plus commit body. Revisit if an OWA options endpoint is adopted.
- **[Risk] layout_guard sizes may break with the new header and pane.** → Add guard checks for 640/1280/1920 px before the visual polish.

## Migration Plan

- No data migration. The new meta key is absent on first run, so defaults apply: Last used with Work week means today's behaviour.
- Rollback: revert the commits. `calendar.prefs` is ignored by older builds.

## Open Questions

- Exact Teams strings for "Show all" and the pane toggle tooltip in German. Use "Alle anzeigen" and "Kalenderliste ein-/ausblenden" until checked against the bundle. Wording only, no behaviour change.
