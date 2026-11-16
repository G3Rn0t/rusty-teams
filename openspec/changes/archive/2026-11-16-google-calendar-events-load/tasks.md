## 1. Propagate Google refresh failure

- [x] 1.1 Change `ensure_access_token` / `fetch_google_events` so a required refresh failure returns `Err` (not a silent empty `Ok`).
- [x] 1.2 Add or adjust a unit test that a refresh-style failure surfaces as `Err`, not `Ok([])`.
- [x] 1.3 Confirm week load still maps Google `Err` into `CalendarLoadFailure` (existing path).

## 2. Local install secret gate

- [x] 2.1 Update `scripts/install-linux-local.sh` to require `TEAMS_GOOGLE_CLIENT_SECRET` and verify `GOCSPX-` in the binary without logging the value.
- [x] 2.2 Clarify ADR 0009: Desktop clients need the secret for refresh.

## 3. Verify live

- [x] 3.1 Sync `.env.google.local` secret into the release worktree and run `install-linux-local.sh --restart`.
- [x] 3.2 Confirm diagnostics show `google=N` with N>0 for a week that has Google events (or a clear Google failure banner if refresh still fails for another reason).
- [x] 3.3 `openspec validate google-calendar-events-load` passes.
