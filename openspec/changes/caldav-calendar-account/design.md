# Design

## Context

Outlook remains the Teams calendar (ADR 0002). Google is the optional OAuth extra (ADR 0009). Linux users also use CalDAV hosts. Today `CalendarSource` / `CalendarProvider` are `Outlook | Google`; week load, merge, create, RSVP, and delete branch on Google. `needs_join_first` only triggers for multi-target or Google, so a CalDAV-only home would write only to Outlook.

## Goals / Non-Goals

**Goals:**

- One CalDAV client for Nextcloud, Fastmail, mailbox.org, Posteo, iCloud, Synology, Radicale (Basic auth + discovery).
- Shared iCalendar core (parse, join-link extraction, RRULE expansion) reusable later for ICS subscriptions.
- Home calendar, write targets, grid merge, local reminders, load-failure banners.
- App password in OS keyring (ADR 0019).

**Non-Goals:**

- Proton/Tuta APIs, Digest auth, TLS bypass, Google-via-CalDAV, sync-token cache, MCP `create_meeting` writing to home, ICS subscriptions in this change.

## Decisions

1. **Modules:** `crates/chatsvc/src/ical/` (parse/expand/write) and `crates/chatsvc/src/caldav/` (discovery, query, PUT/DELETE). Orchestration in `app-state` next to `google_calendar_sync.rs`.
2. **Read path:** `calendar-query` with `time-range` for the visible span (`dates_range`). Prefer `<C:expand>`; fall back to client expansion. Series masters that start before the window must still produce occurrences (fixture test).
3. **Write path:** Any non-Outlook write target mints a Teams join URL first (`needs_join_first`). PUT with `If-None-Match: *` on create; GET+`If-Match` on update; bump `SEQUENCE`. Series occurrence delete = `EXDATE` on master.
4. **Merge:** Prefer Outlook; else the home calendar's copy; else first. Move merge helper under calendar (not Google-only).
5. **Auth:** Basic only. Reject HTTPS→HTTP redirects. Keyring for password; merge pattern like `merge_google_tokens` so a fetch does not overwrite toggles.
6. **Invites:** If Outlook is among write targets, Outlook invites; CalDAV stores attendees without a schedule request. CalDAV-only home: PUT includes attendees; server invites if it supports scheduling.
7. **UI:** Settings calendar page adds CalDAV connect form (URL templates, username, password). Picker lists CalDAV calendars. EN + DE (Swiss orthography). Islands SPEC for existing settings surfaces only.

## Risks / Trade-offs

- Server expand quality varies → client expansion is mandatory fallback.
- Baïkal Digest → clear error; no Digest client.
- Keyring unavailable (sandbox) → connect fails with a clear message; Flatpak must request secrets.
- Slow CalDAV hosts → parallel source loads with timeout; banner on failure, keep other sources.

## Migration Plan

- Existing Google/Outlook accounts unchanged.
- New `caldav_accounts` field in calendar accounts JSON; unknown fields ignored by older builds if serde defaults hold.

## Open Questions

- None blocking; ICS subscription is a follow-up change.
