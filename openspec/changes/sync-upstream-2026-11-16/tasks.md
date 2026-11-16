# Tasks

## 1. Merge

- [x] 1.1 Merge `upstream/main` into Forgejo `main`
- [x] 1.2 Resolve README, ROADMAP, and browser process conflicts so fork Flatpak and macOS toast notes stay
- [x] 1.3 Renumber the macOS toast ADR to 0018 and list it beside guest-org ADR 0017

## 2. Spec

- [x] 2.1 Add `guest-orgs` and update `linux-sign-in` and `macos-sign-in` deltas
- [x] 2.2 `openspec validate sync-upstream-2026-11-16`

## 3. Verify

- [ ] 3.1 `cargo test -p browser --lib` and `cargo test -p chatsvc --lib` on the merge result
