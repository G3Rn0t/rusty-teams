@AGENTS.md

# Claude Code

Claude Code loads this file, not `AGENTS.md`; the import above makes the shared agent notes apply here too.

## OpenSpec first (always)

Every change with observable behaviour starts as an OpenSpec change, before any code:

1. Propose: follow `.cursor/skills/openspec-propose/SKILL.md` (`openspec new change`, proposal, specs, design, tasks). English only.
2. Stop after the artifacts and let the user review them.
3. Apply: follow `.cursor/skills/openspec-apply-change/SKILL.md`, check off `tasks.md` as you go, including the verify tasks.
4. Archive after merge: `.cursor/skills/openspec-archive-change/SKILL.md`.

A plan in plan mode does not replace the OpenSpec change; the plan becomes the proposal. Only pure refactoring, tooling or docs may skip specs (`skip_specs: true`).

CLI: `/usr/local/bin/openspec`.
