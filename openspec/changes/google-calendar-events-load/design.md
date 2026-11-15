# Design

## Context

Week load calls Google Calendar after `ensure_access_token`. On refresh HTTP errors (e.g. `client_secret is missing`), the helper returned `Ok(false)`, so `fetch_google_events` returned `Ok([])` and the week UI never set `CalendarLoadFailure` for Google. Local install baked only the client id.

## Decisions

1. **Propagate refresh failure** — If refresh is required and fails, `fetch_google_events` returns `Err(message)` so week load records `CalendarLoadFailure { source: Google }` and the existing source-failed banner + retry apply. Same for write paths that already map missing token to `Err`.
2. **Install refuses missing secret** — `install-linux-local.sh` exits if `TEAMS_GOOGLE_CLIENT_SECRET` is empty after loading `.env.google.local`, and verifies the binary contains the `GOCSPX-` prefix without logging the secret value.
3. **ADR 0009 clarification** — Desktop OAuth clients from Google Cloud include a secret and need it for refresh; «optional» remains only for public clients with an empty secret.

## Alternatives rejected

- Runtime-only secret via shell: Dock/desktop launches do not inherit developer env (ADR 0009).
- Settings field for secret: rejected by ADR 0009 (project-owned Desktop client).

## Risks

- Operators who only set the client id must add the secret once; install fails loudly until then (intended).
