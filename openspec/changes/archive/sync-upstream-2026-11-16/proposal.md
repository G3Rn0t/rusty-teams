# Proposal

## Why

Upstream `main` moved ahead after merged pull requests (guest orgs, Firefox-family sign-in, chat image loading, outgoing-call answer, ACL no-access copy). The Forgejo fork has to take that behaviour in, while keeping fork-only Flatpak packaging and the macOS tray / Notification Center work that is still an open upstream pull request.

## What Changes

- Bring upstream `main` into Forgejo `main`.
- Sign-in on Linux and macOS follows the default browser when it is Chromium- or Firefox-based, with Settings > General > Teams session browser as the override. Firefox, Zen, LibreWolf, and Floorp use a separate profile.
- The account menu lists home and guest orgs. Choosing another org restarts onto that tenant with its own cache. Orgs that are not open still surface new messages.
- Keep the fork Flatpak release note and the macOS menu-bar tray, Notification Center toasts, and smoke checklist.
- Renumber the fork macOS toast decision to ADR 0018 because upstream shipped guest orgs as ADR 0017.

## Capabilities

### New Capabilities

- `guest-orgs`: One account can open a home or guest tenant from the account menu; the chosen org is the only live window, and other orgs still announce new messages.

### Modified Capabilities

- `linux-sign-in`: Managed sign-in is no longer Chrome-only. Automatic uses the default browser when it is a supported Chromium or Firefox-family browser.
- `macos-sign-in`: Same session-browser choice on macOS, including Firefox-family browsers beside the existing Chromium forks.

## Impact

- Merge of `upstream/main` into Forgejo `main` (browser session, org switch, chat and call fixes already reviewed upstream).
- Docs: `README.md`, `ROADMAP.md`, `docs/decisions/0018-macos-desktop-toasts-use-notification-center.md`.
- Fork-only Flatpak and macOS packaging text stays. Upstream pull request #49 (macOS tray packaging) is still open and is not closed by this sync.
