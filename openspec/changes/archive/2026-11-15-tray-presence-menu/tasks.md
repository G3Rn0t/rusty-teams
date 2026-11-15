## 1. Commands and center wiring

- [x] 1.1 Replace `TrayCommand` variants: drop mute/local DND; add set availability, reset availability, open notifications
- [x] 1.2 Update `poll_tray` / `sync_tray` in `NotificationCenter` to call `set_own_availability` and open `SettingsSection::Notifications`
- [x] 1.3 On notification center start, clear and save a stored `settings.do_not_disturb` if true

## 2. Tray menus

- [x] 2.1 Rebuild Linux `linux_tray` menu: Open, status submenu (choices / duration / reset), Notifications, Quit
- [x] 2.2 Rebuild Windows tray menu with the same structure and commands
- [x] 2.3 Update stubs and locale keys used by the tray; drop unused mute/DND tray strings if nothing else needs them

## 3. Verify

- [x] 3.1 `cargo test -p app-base --lib linux_tray`
- [x] 3.2 Focused tests or compile check that tray commands no longer toggle local DND
- [x] 3.3 `scripts/install-linux-local.sh --restart` and smoke the tray on Hyprland (status, reset, Notifications section, Quit)
