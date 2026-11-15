## ADDED Requirements

### Requirement: RSVP from Upcoming meetings

Upcoming meeting rows that invite the user SHALL offer Accept, Tentative, and Decline (and a Respond menu with optional send-response), matching the peek RSVP controls. Own meetings where the user is the organizer MUST show Organizer instead of invitee RSVP controls. The response MUST follow the event source (Outlook Graph path or Google attendee status) as in RSVP follows event source.

#### Scenario: Accept from Upcoming

- **WHEN** the user accepts an Outlook invitation from an Upcoming row
- **THEN** the response is written through the Outlook path
- **AND** the row reflects the new response state after refresh

#### Scenario: Decline from Upcoming with send response

- **WHEN** the user declines a Google invitation from Upcoming with «Send a response» on
- **THEN** the Google event response becomes declined
- **AND** organizers are notified according to Google's send-updates behaviour

#### Scenario: Organizer row

- **WHEN** the Upcoming row is for a meeting the user organizes
- **THEN** the row shows Organizer
- **AND** invitee Accept / Tentative / Decline controls are not offered

### Requirement: Teams reminder push shares the poll toast path

When a Teams client push that announces an upcoming meeting reminder is proven (channel, payload, and meaning documented under research), the app SHALL start or refresh the same meeting reminder toast path used for `reminderView` polling: Soon / Started / Live phases, Join, Snooze on Soon, Dismiss, and start chime rules. The push MUST NOT invent a second toast UI. Until the push is proven, the app MUST keep discovering reminders by polling alone.

#### Scenario: Proven push triggers Soon toast

- **WHEN** a documented Teams reminder push arrives for an eligible online meeting before start
- **THEN** the meeting toast appears with Join and Snooze
- **AND** behaviour matches a toast raised from the reminder poll for the same meeting

#### Scenario: Unproven push stays unused

- **WHEN** research cannot identify the Teams reminder push payload
- **THEN** reminders continue to come from the calendar / ReminderView poll only
- **AND** the app does not subscribe to an invented push code

## MODIFIED Requirements

### Requirement: Home calendar and write targets

The user SHALL choose one home calendar among available calendars (Outlook mailbox or a connected Google calendar). «New meeting» MUST always write to the home calendar. The user MAY select additional write targets so the same meeting is also created there. The set of targets MUST be extensible when more calendar accounts are added later. A successful New meeting create MUST show the meeting in the calendar grid after the next refresh for each write target that accepted the create.

#### Scenario: Write to home only

- **WHEN** the user creates a new meeting with only the home calendar selected
- **THEN** the meeting is created in that home calendar
- **AND** it is not created in other calendars
- **AND** it appears in the grid after the next refresh

#### Scenario: Write to home and another calendar

- **WHEN** the user creates a new meeting with the home calendar and an additional write target selected
- **THEN** the meeting is created in each selected calendar
- **AND** each created event carries the Teams join link when the meeting is online

#### Scenario: Home is Google without mailbox

- **WHEN** the home calendar is a Google calendar and Outlook create is unavailable
- **THEN** «New meeting» still creates the Teams join link
- **AND** stores the meeting in the selected Google calendar with that join link
