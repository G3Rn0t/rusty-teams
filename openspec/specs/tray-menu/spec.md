# tray-menu Specification

## Purpose
Give the system tray a context menu that matches Teams: change published presence, open notification settings, open the app, and quit. Local mute-only switches that reuse Teams status names MUST NOT appear in the tray.

## Requirements

### Requirement: Tray status submenu publishes presence

When a tray host is available, the tray context menu SHALL offer a status submenu whose title is the user's current presence label. Choosing a status in that submenu SHALL set the same published availability as the in-app profile status menu for that choice. Reset SHALL clear the forced availability the same way the profile menu does.

#### Scenario: User sets Do not disturb from the tray

- **WHEN** the user chooses Do not disturb in the tray status submenu
- **THEN** the app publishes Do not disturb availability so other people see that status
- **AND** notification rules follow presence Do not disturb (urgent messages still notify)

#### Scenario: User resets status from the tray

- **WHEN** the user chooses Reset status in the tray status submenu while a forced status is set
- **THEN** the forced availability is cleared the same way as from the profile status menu

#### Scenario: Tray reflects live presence

- **WHEN** the user's presence or forced status changes while the tray is shown
- **THEN** the status submenu title shows the current presence label
- **AND** at most one forced status choice is checked; when none is forced, no choice is checked

### Requirement: Tray Notifications opens notification settings

The tray item labeled Notifications SHALL raise the main window and open Settings on the Notifications section.

#### Scenario: User opens Notifications from the tray

- **WHEN** the user activates Notifications in the tray menu
- **THEN** the main window is shown or raised
- **AND** Settings opens on the Notifications section

### Requirement: Tray keeps Open and Quit

The tray menu SHALL keep Open (show or raise the main window) and Quit. Left-click on the tray icon MAY continue to toggle the main window, including close-to-tray on Linux.

#### Scenario: User quits from the tray

- **WHEN** the user activates Quit in the tray menu
- **THEN** the application exits

### Requirement: Tray does not offer local mute as Teams Do not disturb

The tray menu MUST NOT offer a Mute sound item or a Do not disturb item that only flips a local notification mute without publishing presence.

#### Scenario: Local mute checkbox is gone

- **WHEN** the user opens the tray context menu
- **THEN** there is no Mute sound item
- **AND** there is no Do not disturb checkbox separate from the status submenu
