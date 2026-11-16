# Proposal

## Why

A push to Forgejo deletes GitHub branches the mirror does not have. That closes an open upstream pull request when its head was never on Forgejo. The rule already says so. Nothing in the clone enforces it.

## What Changes

- Add `.githooks/pre-push` and `scripts/install-git-hooks.sh`.
- The hook rejects pushes to the GitHub fork and to upstream.
- On a push to Forgejo it rejects the push when an open `d0dg3r` → upstream pull request head is missing or would be deleted.
- Document the install step in the fork workflow rule and agent notes.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `fork-delivery`: Everyday pushes stay on Forgejo, and an open upstream pull request head must exist on Forgejo before the next Forgejo push.

## Impact

- Tooling only: git hook and docs. No app behaviour.
