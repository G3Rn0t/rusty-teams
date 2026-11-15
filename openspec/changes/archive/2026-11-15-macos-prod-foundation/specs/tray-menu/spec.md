## ADDED Requirements

### Requirement: macOS hosts a menu-bar tray

On macOS the app SHALL show a menu-bar tray icon when not in demo mode. The tray menu SHALL offer the same Open, status submenu, Notifications, and Quit behaviour as on Windows and Linux. Left-click MAY toggle the main window.

#### Scenario: Tray appears on macOS

- **WHEN** the user runs a non-demo session on macOS
- **THEN** a menu-bar tray icon is present
- **AND** Open, Notifications, Quit, and the status submenu are available

### Requirement: Close to tray on macOS reopens the window

When Close to tray is enabled on macOS and the user closes the main window, the app MUST keep running with the tray. Opening from the tray or a second launch MUST show a main window again (close-and-reopen is allowed when the toolkit cannot hide the window).

#### Scenario: Close then Open from tray

- **WHEN** Close to tray is on and the user closes the main window on macOS
- **THEN** the process stays alive with the tray
- **AND** choosing Open from the tray shows a main window again
