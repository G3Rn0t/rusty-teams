## ADDED Requirements

### Requirement: macOS ScreenCaptureKit picker stays until select or cancel

On macOS the share path MUST keep the ScreenCaptureKit capturer alive while the system picker is open. The app MUST NOT drop the capturer or show a portal-unavailable notice merely because there is no delegated picker controller (that controller is Wayland-only). The first delivered frame MUST mean the user selected a source. A permanent capture error before any frame MUST mean the picker was cancelled or failed to start, without an error toast for a user cancel.

#### Scenario: Picker stays open

- **WHEN** the user chooses to share the screen or a window on macOS
- **THEN** the ScreenCaptureKit system dialog remains available until the user selects a source or cancels
- **AND** the app does not show a desktop-portal-unavailable notice solely for lack of a delegated picker

#### Scenario: First frame starts share

- **WHEN** the user selects a source in the ScreenCaptureKit dialog
- **THEN** frames begin and the app shows local sharing as active

#### Scenario: Cancel stays quiet

- **WHEN** the user cancels the ScreenCaptureKit dialog before any frame
- **THEN** sharing does not start
- **AND** the call stays connected
- **AND** no error toast appears
