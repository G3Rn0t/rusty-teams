@AGENTS.md

# Claude Code

Claude Code loads this file, not `AGENTS.md`; the import above makes the shared agent notes apply here too.

## OpenSpec first (always) — hard stop

Before any product `crates/` edit: create `openspec/changes/<name>/` and run `openspec validate <name>`. CI (`scripts/check-openspec-gate.sh`) fails the build otherwise.

1. Propose: follow `.cursor/skills/openspec-propose/SKILL.md` (`openspec new change`, proposal, specs, design, tasks). English only.
2. Stop after the artifacts and let the user review them.
3. Apply: follow `.cursor/skills/openspec-apply-change/SKILL.md`, check off `tasks.md` as you go, including the verify tasks.
4. Archive after merge: `.cursor/skills/openspec-archive-change/SKILL.md`.

A plan in plan mode does not replace the OpenSpec change; the plan becomes the proposal. Pure refactoring/tooling/docs still create a change with `skip_specs: true` so the CI gate sees `openspec/changes/`.

CLI: `/usr/local/bin/openspec`.
