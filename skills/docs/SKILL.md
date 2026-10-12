---
name: docs
description: >
  Invoke whenever the user asks to write the feature record, distil the feature into the
  project docs, record its decisions, or runs `/specd:docs [feature]`; also as the next step
  after `/specd:verify`. It writes what survives the feature into `<docs_root>/`: the
  feature record, decision files, architecture and data-model deltas, so the pull request
  carries them from the start. It leaves the spec folder in place; `close` removes it after
  the PR is settled. Not for user-facing documentation inside the code; that is a task.
---

# Skill: docs

Durable knowledge goes to `<docs_root>/` before the PR opens, so reviewers see the feature
and its record together. The spec folder stays: `feedback` and the fix loop still read it.
Whether to write at all follows the retention policy, confirmed per feature.

## Gate

`state check --step docs`: `step` is `docs` or later. Re-run after a feedback cycle to
refresh the record.

## Inputs

- `resolve-paths`, `detect-repo` (default branch), `state find`, `state check`.
- `<spec_root>/<feature>/state.yml` (`tier`, `retention`, `pr`), `spec.md`, `design.md`
  (the sections it has), `tasks.md`, `review.md`; `git diff --stat <default>...HEAD` in
  `<code_root>`.
- `<docs_root>/decisions/README.md`, `architecture/overview.md` and areas, `data-models/`,
  `features/` and its `README.md`.
- `<workspace_root>/specd.yml`: `flow.retention`, `git.authority`.
- [`../_shared/paths.md`](../_shared/paths.md), [`../_shared/state-yml.md`](../_shared/state-yml.md),
  `./templates/feature.md`,
  `./templates/features-README.md`,
  [`../_shared/templates/decision.md`](../_shared/templates/decision.md),
  [`./references/distill.md`](./references/distill.md).

## Outputs

- `<docs_root>/features/<feature>.md` and its row in `features/README.md`,
  `decisions/NNNN-*.md` with README rows, approved deltas in architecture or data-model
  files; or nothing, when skipped.
- `step: deliver` in `state.yml`; one commit `docs(<feature>): record` when something was
  written (authority ≠ `none`).

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature"), `state check --step docs`.
   Set `step=docs`.
   Effective policy = `retention` in `state.yml`, else `clean` for trivial and quick,
   `flow.retention` for full. Default is **write** when the policy is `distill`, **skip**
   otherwise; confirm in one question with the default first.
2. **Write** per `distill.md`: (a) copy `./templates/feature.md` to
   `<docs_root>/features/<feature>.md` and fill it from `spec.md` (what it does, the
   behaviour groups), `design.md` (entry points, user flow, approach summary, sequences,
   the Where-it-lives table from Changes by area, interfaces), the diff stat (which planned
   files exist), `tasks.md` and `review.md` (how to verify, notes) and `state.yml` (PR URL
   when already set, else `pending`); sections without a source are omitted. Then append
   the feature's row to `features/README.md`, created from `./templates/features-README.md`
   when missing, or refresh its row; (b) list the `### D<n>`
   blocks of `design.md` with one line each and ask which are durable per the test in
   `distill.md` (default: the ones that pass it); for each kept one copy
   `_shared/templates/decision.md` to `<docs_root>/decisions/NNNN-<kebab-title>.md` with the
   next free number, status accepted, and append its row to `decisions/README.md`; the rest
   stay in the feature record's Notes as one line each; (c) for a `## Data model` or
   `## API and contracts` section, name the `architecture/<area>.md` or
   `data-models/<domain>.md` it changes and propose one patch per file: show it, ask, apply.
   No draft markers on any of these; they are signed off by this run. A record that already
   exists is refreshed, not rewritten (`distill.md`, "Refreshing").
3. **Skip.** Say nothing was written and why (policy); the spec folder is the only record
   until `close`.
4. **Commit** `docs(<feature>): record` with `git -C <docs_root>` (the repo containing the
   paths), when anything was written; `state.yml` with `git -C <workspace_root>` when that is
   another repo. `state set step=deliver`.
5. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced`: the docs
   written, or none. `Review`: decisions recorded, deltas applied. `Next: /specd:deliver
   <feature>`.

## Anti-patterns

- Copying `spec.md` into `features/<feature>.md`; the record is what shipped, in a page.
- AC ids or test evidence in the record; it describes the feature, the matrix leaves with
  the spec folder.
- A flat file list under `Where it lives`; the table with roles is the structure.
- Dropping the design's diagrams because they are long; they are the picture of the feature
  and the spec folder that holds them is deleted at `close`.
- Recording a decision that has no alternatives, or renumbering existing decisions.
- Editing an architecture or data-model doc without showing the patch first.
- Removing the spec folder here; that is `close`, after the PR is settled.
- Writing the record for a trivial feature "to be safe"; the policy decides, the user confirms.
