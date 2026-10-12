---
name: status
description: >
  Invoke whenever the user asks where a feature stands, what to run next, which features
  are open, or runs `/specd:status [feature]`; also whenever a session starts on a repo with
  specd and the user wants to resume after `/clear`. It lists every feature under the spec
  root with tier, step, gates, task progress, review rounds and PR, warns about kept folders
  older than the configured age, and prints the exact next command for the feature named or
  implied by the branch. It reads only; it changes nothing.
---

# Skill: status

The resume point. Files are the state, so this skill only reads them and says what comes
next. It is safe to run at any time and never asks a question.

## Inputs

- `resolve-paths`, `detect-repo` (current branch), `"${CLAUDE_PLUGIN_ROOT}/scripts/state"
  list` and `state find`.
- `<workspace_root>/specd.yml`: `flow.keep_days`.
- [`../_shared/paths.md`](../_shared/paths.md), [`../_shared/state-yml.md`](../_shared/state-yml.md)
  (step meanings).

## Outputs

- None on disk.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /specd:init first`), `detect-repo --from
   <code_root>` (`paths.md`).
2. **List.** `state list --spec-root <spec_root> --worktrees <wrapper_root>/.worktrees`. No features: say so, `Next:
   /specd:start <feature>`. Otherwise print one table: feature, tier (`quick→full` when
   `escalated` is set), step, gates as `G1 G2 G3 G4 G5` with `x` for approved, `.`
   otherwise and `-` for a gate the tier never passes, tasks `done/total`, review
   `round/open`, PR (`yes` or `-`), updated date, and a worktree column (`.worktrees/<name>`
   or `-`) when any row has one. A feature the script reports with an
   `error` gets a row saying `state.yml unreadable: <reason>`.
3. **Warn.** Every feature with `step: closed` whose `updated` is older than `flow.keep_days`
   days: one line, `<feature> kept for <n> days; /specd:close <feature> cleans
   it (spec-clean arrives with M7)`.
4. **Point.** Resolve the feature: the argument, else `state find --branch <current>
   --worktrees <wrapper_root>/.worktrees` (an
   ambiguous result is not an error here: skip this step and say `name a feature to see
   its next command`). For the resolved feature, `Next` is `/specd:<next> <feature>` with
   `next` from the list output (the script turns `start` into the tier's first step and
   names `fix` for a fix feature without a reproduction); `closed` → `nothing to do`;
   `close` with a PR → second line `/specd:feedback <feature>` when comments arrived.
5. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced: none`.
   `Review`: the warnings, or `none`. `State` and `Next` for the resolved feature, or
   `State: <n> features` and `Next: /specd:status <feature>` when none resolved.

## Anti-patterns

- Reading `state.yml` files by hand; `state list` is the reader.
- Guessing a next command for a feature it could not resolve.
- Writing anything, including "fixing" a malformed state file.
- Summarising spec contents; the table and the next command are the whole output.
