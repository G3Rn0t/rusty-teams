## ADDED Requirements

### Requirement: Grid load does not wait for calling

The week and month grid SHALL load Outlook events as soon as the signed-in session is available, independent of the calling service. A grid load that was skipped because no session was ready MUST run once the session becomes available.

#### Scenario: Calendar opened right after sign-in

- **WHEN** the user opens the calendar before the session is ready
- **THEN** the grid loads the visible range as soon as the session is ready, without further navigation

#### Scenario: Calling service still starting

- **WHEN** the session is ready but the calling service has not registered yet
- **THEN** Outlook events of the visible range still appear in the grid

### Requirement: Grid refresh while open

While the calendar view is open, the app SHALL reload the visible range on the calendar poll interval. A visible range that has already loaded MUST keep its events on screen until the reload replaces them.

#### Scenario: Change made elsewhere

- **WHEN** a meeting is added in Outlook for the visible week while the calendar is open
- **THEN** it appears in the grid after the next calendar poll

### Requirement: Load state and source errors

The calendar SHALL show that the visible range is loading. When a selected source fails to load, the calendar MUST show an inline notice naming that source with a Retry action, for every failed load rather than once per session. Events from sources that loaded MUST still show.

#### Scenario: Outlook fails, Google loads

- **WHEN** Outlook fails to load the visible week and a Google calendar loads
- **THEN** the Google events show in the grid
- **AND** a notice says Outlook could not be loaded and offers Retry

#### Scenario: Retry succeeds

- **WHEN** the user chooses Retry and Outlook loads
- **THEN** the notice disappears and the Outlook events show

### Requirement: Calendar toggle survives a running fetch

Turning a calendar on or off SHALL stay in effect when a calendar fetch that started before the toggle completes. Only refreshed sign-in tokens from that fetch MUST be kept.

#### Scenario: Toggle during a fetch

- **WHEN** the user turns a Google calendar off while a calendar fetch is running
- **THEN** the calendar stays off after the fetch completes
- **AND** the check box does not flip back
