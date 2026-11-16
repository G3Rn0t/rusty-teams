# Design

## Context

This change records behaviour that already landed on `danieldaeschle/rusty-teams` `main` and is merged into Forgejo `main`. It does not reopen those upstream pull requests.

ADR numbers collided: the fork had accepted macOS Notification Center as 0017, and upstream accepted guest orgs as 0017. Guest orgs keep 0017 (upstream number). The toast record moves to `docs/decisions/0018-macos-desktop-toasts-use-notification-center.md`. Archived OpenSpec text and the 0.4.0-joe.6 changelog line still say 0017; the ADR file states that rename.

## Goals

- Forgejo `main` contains upstream `main` plus the fork-only commits.
- Sign-in and guest-org behaviour match what upstream shipped.
- Flatpak and macOS daily-driver notes in the README stay.

## Non-goals

- Closing upstream pull request #49.
- Re-specifying Flatpak (`flatpak-package` remains its own change).
- Rewriting archived changelog history.

## Decisions

- Conflict in `crates/browser/src/process.rs` keeps upstream's shared basename helper. Chromium-fork and Firefox-family name checks both use it.
- README platform rows use upstream's browser list and the fork's Flatpak sentence, codesign note, tray, and Notification Center checklist.
- Shell and look are unchanged. Guest org rows use the existing account menu.

## Risks

- Firefox sign-in is still partial upstream (Zen checked on macOS; a full Teams sign-in and Linux were not run there).
- Guest-org background toasts were not run live upstream. Calls stay on the home tenant.
