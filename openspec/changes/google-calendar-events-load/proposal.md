# Proposal

## Why

Google Calendar can show as connected while the week grid stays empty for existing Google events. Token refresh fails when the Desktop OAuth client secret is missing from the build, and the failure is swallowed as a successful empty load — so the user sees no banner and no events.

## What Changes

- When Google is connected and the week load cannot refresh or use an access token, the app MUST report a Google calendar load failure (banner + retry), not a silent empty week.
- Local Linux install that bakes `TEAMS_GOOGLE_CLIENT_ID` MUST also bake `TEAMS_GOOGLE_CLIENT_SECRET` (or refuse the install) so Desktop-client refresh works after Dock/desktop launch.
- After a correct secret rebuild, existing Google events in the visible week range appear in the grid.

## Capabilities

### New Capabilities

- (none)

### Modified Capabilities

- `calendar-accounts`: Surface Google token-refresh / auth failures on week load; local install requires Desktop client secret when baking the client id.

## Impact

- `google_calendar_sync` refresh path and week-load failure list.
- `scripts/install-linux-local.sh` gate + binary verify for secret prefix.
- ADR 0009 wording: Desktop clients need the secret for refresh; «optional» only for true public clients.
- Operator: `.env.google.local` must include the secret before local install.

## Out of scope

- Settings UI to type a client secret.
- Upstream PR for the install gate.
- Outlook load / calendar picker selection bugs unrelated to Google auth.
