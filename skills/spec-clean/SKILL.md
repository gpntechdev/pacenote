---
name: spec-clean
description: >
  Invoke whenever the user asks to clean up, remove or distill old kept spec folders, says
  closed features are piling up under the spec root, follows the `status` warning about
  kept folders older than `flow.keep_days`, or runs `/specd:spec-clean`. It lists every
  feature closed with `keep` and older than the cap with a script, proposes per folder
  delete (the feature record already exists), distill (write the missing record and durable
  decisions, then delete) or skip, and applies only the rows you approve, then commits once
  per repo, never on a default branch. Not for a feature still in flight or one whose PR is open; that is `/specd:close`.
---

# Skill: spec-clean

Kept spec folders are the one retention choice that leaves files behind (`close` with
`keep`); once their PR merged they sit on the default branch, where `close` and `docs` no
longer run. This util clears them in a batch: a folder whose feature record exists simply
goes, one without a record is distilled first, on your choice. The script lists and removes;
the main thread judges and writes records. A util per [`../_shared/utils.md`](../_shared/utils.md):
no `state check`, nothing written without a yes.

## Inputs

- `resolve-paths` ([`../_shared/paths.md`](../_shared/paths.md)); `detect-repo --from <root>`
  for each repo that will change.
- `<workspace_root>/specd.yml`: `flow.keep_days` (default 30), `git.authority`.
- `"${CLAUDE_PLUGIN_ROOT}/scripts/spec-clean" scan` output (it reads every `state.yml`).
- Distill rows only, one folder at a time: `spec.md`, `design.md`, `tasks.md`, `review.md`,
  `state.yml` of `<spec_root>/<feature>/`; `<docs_root>/features/README.md`,
  `<docs_root>/decisions/README.md` and its `NNNN-` file names; Glob under `<code_root>`.
- [`./references/distill.md`](./references/distill.md) (the delta over `docs`' protocol),
  [`../docs/templates/feature.md`](../docs/templates/feature.md),
  [`../_shared/templates/decision.md`](../_shared/templates/decision.md).

## Outputs

- Approved folders removed from `<spec_root>` through `spec-clean apply`; the plan file it
  consumes is never committed.
- Distill rows: `<docs_root>/features/<feature>.md`, its `features/README.md` row, and
  `<docs_root>/decisions/NNNN-<kebab-title>.md` with README rows for approved decisions.
- A `chore/spec-clean-<YYYY-MM-DD>` branch in each changed repo that was on its default
  branch; one commit per changed repo.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /specd:init first`). Read the two keys.
2. **Scan.** `"${CLAUDE_PLUGIN_ROOT}/scripts/spec-clean" scan --spec-root <spec_root>
   --docs-root <docs_root> --worktrees <wrapper_root>/.worktrees --days <flow.keep_days>`.
   Print `kept folders: <old> older than <days> days, <fresh> younger` and one line per
   `blocked` or `errors` row with its reason (they are never touched). No `old` row: say so,
   end with the handoff.
3. **Propose.** For each distill candidate (no record), read its `design.md` `### D<n>`
   headings (quick: none) and judge each by the durability test in
   `../docs/references/distill.md`. Print one table, oldest first:
   `<feature> · <age>d · <tier> · record yes|no · delete | distill | skip · <reason>`.
   Defaults: record yes → `delete` (`record exists`); record no → `distill` on full,
   `delete` on trivial and quick (their policy never wrote one). Below it, per distill row:
   `D<n> <title> → decision | notes`. Name the branch the run will commit to (step 5).
4. **Ask** one question per `utils.md`: apply all, adjust, cancel. Adjust: apply the user's
   changes (`auth skip`, `billing distill`, `billing D2 decision`), reprint the changed rows,
   ask again. Cancel or every row `skip`: handoff, nothing written.
5. **Branch** per `utils.md` "Branch". The repos that will change are the one holding
   `<spec_root>`, plus the one holding `<docs_root>` when a distill row exists and it is
   another repo.
6. **Distill** each approved distill row, one folder at a time, per
   [`./references/distill.md`](./references/distill.md): the record from the template, its
   README row, the approved decisions with README rows. Read the next folder only after the
   previous record is written.
7. **Remove.** Write `[{feature, updated}]` (the scanned `updated`, one entry per delete and
   distill row) to `<workspace_root>/.spec-clean-plan.json` and run `spec-clean apply
   --spec-root <spec_root> --plan <that path> --worktrees <wrapper_root>/.worktrees`; the
   script deletes the plan on success. Never pass the JSON inline. A refusal means a folder
   changed: re-scan and go back to step 3; records already written stay and are committed
   with the next run.
8. **Commit** per `utils.md`, one per changed repo; no commit on `git.authority: none` (say
   the files are left unstaged). In the repo holding `<spec_root>`: `git add -A --` the
   removed folders, plus the docs files when the same repo holds them, then `spec(spec-clean):
   distill d, delete c` (non-zero verbs only; each removed folder counts once, `distill` when
   its record was written in this run). In a separate docs repo: `docs(spec-clean): distill d`.
9. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced`: the removed
   folders and the docs written. `Review`: decisions written; records with planned paths that
   no longer exist; the branch per repo, and that pushing and any PR are yours.
   `State: spec-clean`. `Next: none`, or the command the user was running.

## Anti-patterns

- Proposing or removing a fresh, open, blocked or skipped folder; the scan decides what is old,
  the user decides what goes.
- Removing a folder with `rm`, `git rm` or a file tool; `spec-clean apply` is the only remover.
- Running `/specd:docs` for a closed feature (it refuses) or editing architecture and
  data-model files from an old design; this run writes the record and decisions only.
- Writing a record for a folder the user marked `delete`, or one question per folder.
- Removing a worktree or merging anything; a blocked row goes back to `/specd:close`.
