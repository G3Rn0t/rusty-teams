## ADDED Requirements

### Requirement: Scroll to work start when today is not visible

When the day or week grid is opened, its span is changed, or the user navigates to a range that does not contain today, the app SHALL scroll the hour grid so the work start time sits near the top of the viewport. It MUST NOT rest at midnight in that case.

#### Scenario: Next week on a Sunday

- **WHEN** today is Sunday, Work week shows next week, and work hours start at 08:00
- **THEN** the hour grid opens with 07:30 at the top of the viewport

#### Scenario: Navigate to another week

- **WHEN** the user goes to the next week from a week that showed today
- **THEN** the hour grid scrolls to work start

#### Scenario: Back to today

- **WHEN** the user chooses Today and today is in the resulting range
- **THEN** the current-time alignment applies again, not work start
