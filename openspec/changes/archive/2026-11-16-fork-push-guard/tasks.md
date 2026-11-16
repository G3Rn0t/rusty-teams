# Tasks

## 1. Hook

- [x] 1.1 Add `.githooks/pre-push` and `scripts/install-git-hooks.sh`
- [x] 1.2 Refuse GitHub-fork and upstream pushes, and Forgejo pushes that drop an open upstream PR head
- [x] 1.3 Keep `exit` in the hook process, not in a piped subshell

## 2. Docs

- [x] 2.1 Update the fork workflow rule, `AGENTS.md`, and the `fork-delivery` spec
- [x] 2.2 `openspec validate fork-push-guard`

## 3. Verify

- [x] 3.1 Hook cases: GitHub push blocked, upstream push blocked, missing head blocked, delete blocked, head present allowed, head included in the same push allowed
