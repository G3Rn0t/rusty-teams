# Proposal

## Why

The tray menu labels "Do not disturb" and "Notifications" do not match what they do. The first only toggles a local mute flag that others never see; the second opens Settings on General. Real Teams (Windows tray since March 2025) shows and changes published presence from the tray. The app already does that correctly in the profile status menu.

## What Changes

- Tray **status** becomes a submenu that sets and clears the same published availability as the profile status menu (six presence choices, duration, reset).
- Tray **Notifications** opens Settings on the Notifications section.
- Tray removes **Mute sound** and the local **Do not disturb** checkbox.
- Clear a previously saved local `do_not_disturb` mute so users are not stuck silent with no tray switch left.
- Keep Open, left-click toggle / close-to-tray, and Quit as they are.

## Capabilities

### New Capabilities

- `tray-menu`: System tray context menu content and actions for presence, notification settings, open, and quit.

### Modified Capabilities

- (none)

## Impact

- Linux StatusNotifierItem tray (`ksni`) and Windows tray menu.
- Notification center tray poll/sync wiring.
- Own-status / forced availability (already used by the profile menu and `/dnd`).
- One-time migration of the orphaned local mute flag.
- Upstream slice: [PR #40](https://github.com/danieldaeschle/rusty-teams/pull/40) (code only; OpenSpec stays on the fork).
