# Agent notes — rusty-teams

## Forgejo SoT vs Upstream

Required workflow (Cursor rule `.cursor/rules/fork-workflow.mdc`, `alwaysApply`):

- **`origin`** (`forgejo.lan/devops-geek/rusty-teams`) = SoT; develop, push, tags, releases
- **`github`** (`d0dg3r/rusty-teams`) = offsite mirror only. Never push, never open branches, never commit there. `git push github` is rejected by `.githooks/pre-push`
- **`upstream`** (`danieldaeschle/rusty-teams`) = fetch + thin PRs only. Never `git push upstream`
- Everyday commits and feature branches go to **`origin`** (Forgejo). Install the hook once per clone: `scripts/install-git-hooks.sh`. Do not pass `--no-verify`
- Upstream PRs: branch from current `upstream/main`, one topic, **push the head to Forgejo first**, let the mirror copy it to GitHub, then `gh pr create` against `danieldaeschle/rusty-teams`
- An `origin` push (including a merge to `main`) makes the Forgejo mirror **delete any GitHub branch that is not on Forgejo**, which closes the upstream PR (`head_ref_deleted`, actor often `d0dg3r`). The pre-push hook blocks that push until every open `d0dg3r` → upstream PR head exists on `origin`. Do not delete those heads while the PR is open. See `.cursor/rules/fork-workflow.mdc`
- Releases: tags like `v0.3.0-joe.1` on Forgejo; GitHub gets the same assets via mirror (`GITHUB_RELEASE.md`)
- Local install: `scripts/install-linux-local.sh --restart` only. A bare `cargo build` + copy lacks `TEAMS_GOOGLE_CLIENT_ID` (from `.env.google.local`) and drops every Google calendar.
## OpenSpec

Product behaviour lives under `openspec/` (config: `openspec/config.yaml`). Skills: `/opsx-propose`, `/opsx-apply`, `/opsx-update`, `/opsx-archive`, `/opsx-sync`, `/opsx-explore`.

**Language: English only** for all OpenSpec artifacts (proposal, design, tasks, specs, archives). Rule: `.cursor/rules/openspec-english.mdc` (`alwaysApply`). App UI may still offer German; that is product chrome, not OpenSpec authoring language.

**OpenSpec first (no exceptions).** Rule: `.cursor/rules/openspec-first.mdc` (`alwaysApply`). Every plan for observable behaviour starts with an OpenSpec change under `openspec/changes/` before code, smoke, or Roadmap Done. A Cursor plan does not replace the change. Smoke-only or «already coded» does not skip it. Only pure refactoring, tooling, or docs with no behaviour change may use `skip_specs: true`.

1. Observable behaviour changes → first a change under `openspec/changes/` (`/opsx-propose`).
2. Implement with `/opsx-apply`; check off tasks including verify (`cargo test …`).
3. After merge on the fork: `/opsx-archive` (deltas into `openspec/specs/`).
4. Bugfix with no new behaviour, pure refactoring/tooling/docs → `skip_specs: true`.

CLI: `/usr/local/bin/openspec` (rule `openspec-cli-path`). Do not report «missing» without a PATH check.

## UI look and shell

Chrome, islands, spacing, radii, type, and colour roles: `docs/design/islands/SPEC.md` (rule `ui-spec`, `GUARDRAILS.md` Look). Feature OpenSpecs describe content and behaviour on those surfaces; they do not invent look tokens.
