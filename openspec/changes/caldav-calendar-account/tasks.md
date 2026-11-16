## 1. Provider model and merge

- [x] 1.1 Add `CalDav` to `CalendarSource` / `CalendarProvider`, `caldav_accounts` on `CalendarAccounts`, disconnect and home fallback
- [x] 1.2 Generalise merge preference (Outlook, else home, else first); move merge beside calendar
- [x] 1.3 Fix `needs_join_first` for any non-Outlook write target; add CalDAV branch in `meeting_create`
- [x] 1.4 Extend week load for CalDAV in parallel with timeout; failures as banners; token/password merge without clobbering toggles
- [x] 1.5 Wire RSVP, delete, reminders, and dialog branches for CalDAV (local snooze/dismiss)

## 2. iCalendar core

- [x] 2.1 Parse VEVENT (UID, DTSTART/DTEND/DURATION, all-day exclusive end, SUMMARY, STATUS, TRANSP, ORGANIZER/ATTENDEE, VALARM, DESCRIPTION) with folding/escaping
- [x] 2.2 Extract Teams join URL from X-MICROSOFT-SKYPETEAMSMEETINGURL, URL, LOCATION, DESCRIPTION
- [x] 2.3 Expand RRULE/RDATE/EXDATE and RECURRENCE-ID overrides into the visible window; group multiple VEVENT in one VCALENDAR
- [x] 2.4 Resolve TZID via chrono-tz, Windows→IANA map, floating as local; emit simple RRULE matching existing Google write helpers

## 3. CalDAV client

- [x] 3.1 Discovery (well-known, principal, calendar-home-set, calendar-user-address-set); reject HTTPS→HTTP; Basic only
- [x] 3.2 List VEVENT calendars with display name, colour, write privilege; skip VTODO-only
- [x] 3.3 `calendar-query` with time-range; prefer expand; client expand fallback; size limit
- [x] 3.4 PUT create (`If-None-Match: *`), GET+PUT update (`If-Match`, SEQUENCE), DELETE, series occurrence via EXDATE, RSVP PARTSTAT

## 4. Security and UI

- [x] 4.1 Store app password in OS keyring; SQLite holds metadata only; redact in diagnostics/support bundle
- [x] 4.2 Settings CalDAV connect form with URL templates; EN + DE (Swiss orthography); picker lists CalDAV calendars
- [x] 4.3 Note Flatpak `org.freedesktop.secrets` for the flatpak-package change

## 5. Verify

- [x] 5.1 Unit tests: parser folding, exclusive all-day, multi-VEVENT, expansion (EXDATE, override, DST Europe/Zurich, series older than window), Windows TZ, merge preference, `needs_join_first` CalDAV-only
- [x] 5.2 HTTP fixtures for PROPFIND/REPORT; optional Radicale smoke when available
- [x] 5.3 `cargo test -p chatsvc -p store -p app-state --lib`
