# Spec Delta

## ADDED Requirements

### Requirement: Google week-load auth failure is visible

When at least one Google account is connected and the calendar week load cannot obtain a usable Google access token (including a failed token refresh), the application MUST treat the Google source as failed for that load. The user MUST see the existing calendar source-failed notice for Google and MUST be able to retry. The application MUST NOT present a successful empty Google week when the only reason no Google events appear is an auth or refresh failure.

#### Scenario: Token refresh fails while Google is connected

- **WHEN** a Google account is connected and the week load needs to refresh the access token
- **AND** the refresh request fails (for example because the Desktop client secret is missing from the build)
- **THEN** the calendar shows a Google source-failed notice with retry
- **AND** the load is not reported as a successful Google week with zero events for that auth failure

#### Scenario: Events appear after a correct Desktop client build

- **WHEN** the release or local install includes both the project Desktop client id and client secret
- **AND** a Google account is connected with a valid refresh token
- **AND** the visible week range contains Google calendar events on selected calendars
- **THEN** those events appear in the calendar grid after a successful week load

### Requirement: Local Linux install bakes Desktop client secret

A local Linux install that compiles in `TEAMS_GOOGLE_CLIENT_ID` MUST also compile in a non-empty `TEAMS_GOOGLE_CLIENT_SECRET` from the environment or `.env.google.local`. If the secret is missing, the install MUST fail before replacing the installed binary. The install MUST verify the built binary contains the Google Desktop secret prefix without printing the secret value.

#### Scenario: Install refused without secret

- **WHEN** the operator runs the local Linux install script with a client id set and an empty or missing client secret
- **THEN** the script exits with a non-zero status and does not install a binary that can only Connect once before silent empty weeks

#### Scenario: Install with id and secret

- **WHEN** the operator runs the local Linux install script with both client id and client secret set
- **THEN** the installed binary can refresh Google tokens after Dock or desktop launch without requiring shell-exported credentials
