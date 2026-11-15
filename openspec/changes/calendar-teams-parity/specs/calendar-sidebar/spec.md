## Purpose

The calendar list pane on the left of the calendar, laid out like Teams: heading, mini month for navigation, Add calendar, and collapsible calendar groups with show/hide toggles.

## ADDED Requirements

### Requirement: Mini month navigation

The calendar list pane SHALL show a mini month with the visible range marked, today marked in the accent colour, and controls for the previous and next month. Clicking a day MUST show the span that contains that day. The mini month MUST follow the grid's navigation until the user moves the mini month on its own.

#### Scenario: Pick a day

- **WHEN** the user clicks 2026-11-25 in the mini month while Week is shown
- **THEN** the grid shows the week that contains 2026-11-25
- **AND** the mini month marks that week

#### Scenario: Follows navigation

- **WHEN** the user goes to the next month with the header arrows in Month
- **THEN** the mini month shows that month

### Requirement: Add calendar

The calendar list pane SHALL offer Add calendar, which opens Settings › Calendar.

#### Scenario: Add calendar

- **WHEN** the user chooses Add calendar
- **THEN** Settings opens on the Calendar page

### Requirement: Calendar groups

The calendar list SHALL group calendars: "My calendars" holds the Outlook mailbox, and each connected Google account has its own group titled with the account address. Each group MUST collapse and expand with its chevron, and its collapsed state MUST be remembered.

#### Scenario: Collapse a group

- **WHEN** the user collapses the Google account group
- **THEN** its calendars are hidden in the list but their events stay in the grid
- **AND** the group is still collapsed after a restart

### Requirement: Group toggle

Each group header SHALL carry a check box that turns all calendars of the group on or off. It MUST show as checked when all are on and as unchecked when none is on.

#### Scenario: Turn a whole account off

- **WHEN** the user unchecks the Google account group
- **THEN** every calendar of that account is turned off and its events leave the grid

### Requirement: Show all

A group with more than five calendars SHALL show only the calendars that are on and the primary one, followed by Show all, which lists every calendar of the group.

#### Scenario: Long Google group

- **WHEN** a Google account has eight calendars with two turned on
- **THEN** the group lists the primary and the two turned on, then Show all
- **AND** choosing Show all lists all eight
