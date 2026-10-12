# specd

Spec-driven development workflow for AI coding assistants, packaged as a Claude Code plugin.
Stack-agnostic; works embedded in a code repo or as a wrapper around it.

The plan of record is `docs/PLAN.md`. Read it before any design work; decisions there win over
anything in this file. Record changes to decisions in `docs/DECISIONS.md`, not in chat.

## Layout

```
.claude-plugin/   plugin.json, marketplace.json
skills/<name>/    SKILL.md (spine) + references/ + templates/
skills/_shared/   blocks referenced by many skills: handoff, gate protocol, principles
agents/           subagent definitions
hooks/            gate enforcement, secrets guardrail
scripts/          deterministic helpers: validate, resolve-paths, detect-*, config-set,
                  init-workspace, state, worktree, run-checks, squash-wip, pr-comments
docs/             PLAN.md, DECISIONS.md, AUTHORING.md
```

## Authoring rules (full version: docs/AUTHORING.md)

- `SKILL.md` is a short spine, ≤150 lines. Detail goes in `references/` and `templates/`,
  loaded on demand. Descriptions are written as triggers.
- Shared text lives once in `skills/_shared/` and is referenced, never copied.
- Every step declares its inputs and outputs and reads only those files. State passes
  through disk (`state.yml`, spec files), not through conversation.
- Subagents return a bounded summary with file:line pointers, never file dumps.
- Deterministic work (command detection, static audit, state validation) is a script in
  `scripts/`, not a prompt.
- No skill hardcodes paths; resolve `workspace_root`, `code_root`, `docs_root` from `specd.yml`.
- Model tiers are roles (`judgment`, `execution`, `cheap`), never model names.

## Coding principles (apply to this repo too)

Think before coding: state assumptions, ask when ambiguous. Simplicity first: the minimal
thing that solves the exact problem, no speculative features or single-use abstractions.
Surgical changes: touch only what the task needs, match existing style. Goal-driven: every
task has a verifiable done-when.

## Working here

- Naming: prefix `/specd:`, config `specd.yml`, embedded folder `.specd/`.
- Use plan mode for anything that sets a convention others will copy.
- Run `scripts/validate` and `claude plugin validate .` before finishing a task.
- Commits: Conventional Commits, no AI attribution lines.
