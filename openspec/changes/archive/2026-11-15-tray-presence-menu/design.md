# Design

## Context

Linux tray (`crates/app-base/src/notify/platform/linux_tray.rs`) and Windows tray (`windows_impl.rs`) previously exposed Open, Mute sound, Do not disturb (local `settings.do_not_disturb`), Notifications (opened `SettingsSection::General`), and Quit. The profile status menu already publishes presence through `AppState::set_own_availability` and `STATUS_CHOICES` / `STATUS_DURATIONS` in `crates/app-state/src/own_status.rs`.

Teams Windows tray (March 2025) shows current presence and lets the user change it; Quit stays in the tray. Jump-list actions (meetings, new chat) are out of scope.

Upstream already fixed Notifications → Notifications settings and DND → published presence as a checkbox (`0e3132f` / #36). This change goes further: full status submenu like the profile menu, and drops Mute sound.

## Goals / Non-Goals

- Goals: tray status = published presence; Notifications opens Notifications settings; remove local mute/DND from the tray; migrate orphaned local flag.
- Non-Goals: jump-list / quick meeting actions; removing `settings.do_not_disturb` from the rules engine; changing close-to-tray; shipping OpenSpec to upstream.

## Decisions

1. **TrayCommand carries presence actions** — Replace `ToggleSound` / `ToggleDoNotDisturb` with set-availability (`ForcedAvailability`), reset-availability, duration, and open-notifications. `poll_tray` in `NotificationCenter` calls `set_own_availability` / opens `SettingsSection::Notifications`.
2. **Shared labels** — Menu strings for status choices reuse `choice_label` / `state_label` from `own_status` / `tray_status`, not a second tray wording.
3. **sync_tray** — Pass forced kind (for checks) and live presence label (for submenu title) so the menu updates when presence changes without rebuilding the whole tray host.
4. **ksni SubMenu / Windows submenu** — Status choices, duration, and reset live in a submenu matching `state_menu` in `status_menu.rs`.
5. **Clear local DND once** — On notification-center start, if `settings.do_not_disturb` is true, set it false and save. The field remains in settings/rules for safety; the tray never writes it again.
6. **Upstream vs fork** — Code lands as a thin upstream PR (#40). OpenSpec artifacts stay on the Forgejo fork and archive into `openspec/specs/` after the fork merges the behaviour.

## Risks / Trade-offs

- Users who relied on local mute-without-presence lose that tray switch. They can use mute-in-calls / notification settings, or publish Do not disturb.
- Windows tray-icon crate submenu APIs differ from ksni; both must offer the same commands.

## Migration Plan

One-time clear of stored `do_not_disturb` when the notification center loads settings after this change.
