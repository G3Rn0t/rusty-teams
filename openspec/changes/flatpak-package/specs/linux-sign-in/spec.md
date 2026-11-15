# Spec Delta

## ADDED Requirements

### Requirement: Flatpak finds packaged Chrome by name

On Linux, when the app runs as Flatpak and no `--endpoint` is given, the managed browser search MUST resolve `google-chrome` from the sandbox PATH (the packaged wrapper) before failing. The app MUST NOT require host PATH or host filesystem mounts for that discovery.

#### Scenario: Sandbox PATH provides google-chrome

- **WHEN** the Flatpak starts without `--endpoint` and `google-chrome` is on the sandbox PATH
- **THEN** the app starts that browser on the debug port with the managed profile under the Flatpak XDG data folder
- **AND** sign-in proceeds without asking the user to grant host filesystem access
