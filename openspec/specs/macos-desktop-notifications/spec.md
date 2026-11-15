# macos-desktop-notifications Specification

## Purpose
Shows chat, call, meeting, and agent alerts on macOS through Notification Center so users see them when the main window is in the background, using the same show/hide policy as Linux desktop notifications.

## Requirements

### Requirement: Message toast on macOS

When a chat message would show a desktop toast under the existing notification rules, macOS MUST show a Notification Center notification with the same title and body policy the Linux desktop path uses. Preview off MUST hide message content. A later message in the same chat MUST replace the previous notification for that chat.

#### Scenario: New direct message

- **WHEN** a direct message arrives and the notification rules allow a toast
- **THEN** a Notification Center notification appears with the sender name and preview text

#### Scenario: Preview disabled

- **WHEN** the account setting hides message preview and a toast is shown
- **THEN** the notification body does not include the message text

### Requirement: Incoming call notification on macOS

An incoming ring MUST show a Notification Center notification that stays until the ring ends or the user acts. Activation MUST bring the app forward for the ring UI. Named action callbacks are best-effort on macOS.

#### Scenario: Audio ring

- **WHEN** an audio call rings and the main window is not handling it in the foreground
- **THEN** a Notification Center notification is shown for the ring

### Requirement: Meeting reminder notification on macOS

A meeting start reminder MUST show a Notification Center notification. Phase changes for the same meeting MUST replace the same notification.

#### Scenario: Soon phase

- **WHEN** a meeting enters the Soon reminder phase
- **THEN** a Notification Center notification is shown for that meeting

### Requirement: App sound, Notification Center silent

The app MUST continue to play its notification and ring tones under the existing sound rules. Notification Center presentation MUST NOT replace those app tones.

#### Scenario: Message with sound on

- **WHEN** a toast is shown and notification sound is enabled
- **THEN** the app plays its notification tone
