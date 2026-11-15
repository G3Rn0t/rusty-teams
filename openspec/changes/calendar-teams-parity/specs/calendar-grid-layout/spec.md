## Purpose

Defines what the calendar day, week and month grids show, so they read like the Teams calendar: day headers, grid lines, work-hour shading, the now line, event block content and calendar colours, the header controls, and localized strings.

## ADDED Requirements

### Requirement: Day headers

Each day column header in Day, Work week and Week SHALL show the day number and below it the full weekday name in the app language. Today's header MUST use the accent colour and carry the accent bar on top.

#### Scenario: German weekday names

- **WHEN** the app language is German and the grid shows Monday 2026-11-16
- **THEN** that header shows "16" and "Montag"

#### Scenario: Today header

- **WHEN** today is in the visible range
- **THEN** its header number and name use the accent colour with the accent bar on top

### Requirement: Hour grid lines

The hour grid SHALL draw a line at each hour and a lighter minor line at each time-scale step inside the hour. Lines stay solid, as the islands look requires. Hour labels MUST sit at the top of their hour line and follow the regional 12-hour or 24-hour clock.

#### Scenario: Twenty-four hour clock

- **WHEN** the regional format uses a 24-hour clock
- **THEN** the hour labels read like "07:00"

#### Scenario: Twelve hour clock

- **WHEN** the regional format uses a 12-hour clock
- **THEN** the hour labels read like "7 AM"

### Requirement: Work-hour shading

Time outside the work hours, and whole non-work days shown in Week or Day, SHALL be shaded darker than work time in the hour grid.

#### Scenario: Evening shaded

- **WHEN** work hours are 08:00–17:00 and the grid shows a work day
- **THEN** the area from 17:00 to midnight and from midnight to 08:00 is shaded

#### Scenario: Weekend shaded in Week

- **WHEN** Week shows Saturday and Saturday is not a work day
- **THEN** Saturday's whole column is shaded

### Requirement: Now line across the week

While today is in the visible range of Work week or Week, a thin, light now line SHALL run across all visible day columns at the current time. In today's column the line MUST be in the accent colour, thicker, with a dot at its left edge.

#### Scenario: Now line on other days

- **WHEN** Week shows today and two other days
- **THEN** the other day columns show a thin, light line at the current time
- **AND** today's column shows a thicker accent line with a dot

### Requirement: Event block content

A timed event block SHALL show the title in bold and the organizer on the same line after it. Taller blocks show more title lines. A block of a recurring meeting MUST show a series icon. Join on the block and the source label stay as they are.

#### Scenario: Short meeting

- **WHEN** a 30-minute meeting "Daily Standup" organized by Zulal is shown at the 30-minute time scale
- **THEN** the block reads "Daily Standup" in bold followed by "Zulal" on one line

#### Scenario: Series icon

- **WHEN** the event is an occurrence of a recurring series
- **THEN** its block shows the series icon

### Requirement: Calendar colour

Each calendar SHALL have a colour: Outlook uses the accent colour, and other calendars take the next colour from the app's calendar colour sequence in the order the calendar list shows them. Event blocks, all-day chips, month chips and the calendar list check box MUST use that colour.

#### Scenario: Google calendar colour

- **WHEN** a Google calendar is the first one after Outlook in the calendar list
- **THEN** its events and its check box use the first colour after the accent in the sequence

### Requirement: Calendar header controls

The calendar header SHALL show, from left: a pane toggle that shows or hides the calendar list pane, Today, previous, next, the date range with its date picker, then on the right the view menu, Join with an ID, Meet now and New meeting. The pane state MUST be remembered.

#### Scenario: Hide the calendar list

- **WHEN** the user chooses the pane toggle while the calendar list is shown
- **THEN** the calendar list hides and the grid takes its width
- **AND** the list stays hidden after a restart until the user shows it again

### Requirement: Localized calendar strings

All texts of the calendar grid, the calendar list and Settings › Calendar SHALL follow the app language, using Teams wording where Teams has the string.

#### Scenario: German calendar

- **WHEN** the app language is German
- **THEN** the header shows "Heute", the view menu offers "Tag", "Arbeitswoche", "Woche" and "Monat", and the calendar list shows "Meine Kalender"
