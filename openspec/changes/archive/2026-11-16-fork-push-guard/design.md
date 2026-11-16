# Design

## Context

Forgejo push-mirrors this repo to `d0dg3r/rusty-teams` and deletes GitHub refs that Forgejo does not have. Upstream pull requests use those mirrored heads.

## Decision

The hook reads the pre-push ref lines Git already passes on stdin. GitHub-fork and upstream URLs are rejected when the push updates or deletes a ref. Forgejo pushes ask `gh` for open pull requests whose head owner is `d0dg3r`, then `git ls-remote --heads origin`. A head that is neither already on origin nor in this push blocks the push. A delete of that head blocks the push.

The open-PR loop is not a pipeline into `while`. A pipe would run `exit` in a subshell and the hook would succeed.

`core.hooksPath` points at the common git dir so every worktree runs the same hook. The wrapper prefers `.githooks/pre-push` in the current checkout.

## Non-goals

- Installing the hook automatically on clone. The install script is one explicit step.
- Blocking pushes when `gh` is missing by skipping the check. A missing `gh` or a failed query blocks the Forgejo push.
