# Proposal

## Why

The calendar does not behave or read like the Teams calendar. A side-by-side check on Sunday 2026-11-15 showed:

- The view always opens in Work week and forgets the user's choice.
- On a weekend, Today lands on next week, without a today marker or now line.
- When today is not on screen, the hour grid rests at midnight.
- The week of 16–20 November stayed empty. Outlook returns three events for it (Daily Standup on Monday and Thursday, a Wednesday meeting), so this is a real bug.
- The left pane, the day headers, the grid lines and the event blocks look clearly different from Teams.
- The grid strings are English only.

This change brings behaviour to Teams parity and the look as close as the islands spec allows. It keeps our additions: Google calendars, Join on the block, the source label, the context menu and follow-now.

## What Changes

- **Default view setting.** Settings › Calendar gets a Default view: Last used, Day, Work week, Week, Month. Last used is the default. The calendar remembers the last chosen span across restarts.
- **Work week and hours from the mailbox.** Work days and work hours are read from and written to the Outlook mailbox working hours, the same setting Teams and Outlook use. They define:
  - which days Work week shows;
  - where the grid scrolls when today is not visible;
  - which hours are shaded as outside work time.
- **First day of week.** The default comes from the regional format. A local override offers Monday, Sunday or Saturday. It applies to Week, Work week, Month and the mini month.
- **Time scale.** A choice of 15, 30 or 60 minutes. Teams uses 30 by default, which becomes our default too. It sets the row height and the minor grid lines.
- **Weekend Work week.** A choice between showing this week or next week when today is not a work day. Next week stays the default.
- **Scroll target.** When today is not in the visible range, the hour grid opens at work start, not at midnight.
- **Grid look.** The grid moves toward the Teams look:
  - Day headers show the day number and the full localized weekday name.
  - The hour grid draws a full line per hour and a dashed line per time-scale step.
  - Time outside work hours is shaded.
  - A dashed now line runs across all visible days and becomes solid with a dot in the today column.
  - Event blocks show title and organizer on one line, with a series icon and the colour of their calendar.
- **Header.** A pane toggle shows or hides the left pane. The "Calendar" title moves into the left pane. The view dropdown keeps its place.
- **Left pane like Teams.** It shows:
  - a "Calendar" heading;
  - a mini month that marks the visible range and navigates on click;
  - "Add calendar", which opens Settings › Calendar;
  - collapsible groups ("My calendars" for Outlook, one per Google account), each with a group toggle;
  - check boxes in the calendar's colour;
  - "Show all" for long groups.
- **Reliable grid load.**
  - Outlook events load as soon as the sign-in session is ready, without waiting for the calling engine.
  - A load skipped because nothing was ready is retried once it is.
  - The visible range refreshes on the calendar poll interval while the calendar is open.
  - A loading state is visible.
  - A failed source shows an inline notice with Retry.
  - Toggling a calendar is never undone by a fetch that was already running.
- **Localized calendar strings.** The grid, the left pane and Settings › Calendar use the app's de/en strings, with Teams wording where Teams has the string.

Out of scope, pending research of the Teams calendar bundle:

- the Filter menu;
- the Meet now and New split buttons;
- "Get a link to share";
- the Teams time-zone settings.

These keep today's behaviour, and no placeholder UI is added for them.

## Capabilities

### New Capabilities

- `calendar-view-settings`: default view and last used span, first day of week, mailbox work days and hours, time scale, weekend Work week.
- `calendar-grid-layout`: what the day, week and month grids show:
  - day headers;
  - grid lines per time scale;
  - work-hour shading;
  - the now line across the week;
  - event block content and calendar colour;
  - the header pane toggle;
  - localized strings.
- `calendar-sidebar`: the left pane with heading, mini month, Add calendar, calendar groups with group toggle and collapse, colour check boxes, Show all, and show/hide.

### Modified Capabilities

- `calendar-now-view`: when today is not visible, open, Today and navigation scroll to work start instead of the top of the day.
- `calendar-accounts`: the grid loads independently of the calling engine and retries after a skipped load. It refreshes on the poll interval while open, shows loading and per-source errors, and keeps a calendar toggle through a concurrent fetch.

## Impact

- **Model:** `crates/app-call-model` (`week_grid`, `calendar_now`, new calendar preferences).
- **State:** `crates/app-state` (`call/week.rs`, `app_state.rs`, `calendar_accounts_actions.rs`, the calendar poll in `backend.rs`).
- **Mailbox settings:** `crates/graph`. Read and write `/me/mailboxSettings` working hours with the `MailboxSettings.ReadWrite` scope, which the Teams client already holds. Checked live: read returns HTTP 200.
- **Store:** `crates/store`. A new meta key for local calendar preferences, and a token merge helper for calendar accounts.
- **UI:** `crates/app` (`views/calendar_view.rs`, `calendar_picker.rs`, `calendar_date_picker.rs`, `calendar_month.rs`, `settings/calendar.rs`, `layout_guard.rs`).
- **Strings:** `crates/app-base/locales/app.yml` (new `calendar.view.*` and `settings.calendar.*` keys) and `crates/app-base/src/format.rs` (localized weekday names).
- **Theme and look spec:** `crates/app-base/src/theme.rs`, a calendar colour helper over existing palette roles. `docs/design/islands/SPEC.md` notes that role.
- **Endpoints:** `docs/research/internal-endpoints.md` is unchanged. Mailbox settings use Graph.
