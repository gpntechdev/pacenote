# Utils

**Reference-only.** Not a skill. The conventions every util follows (`lessons-prune`,
`spec-clean`, `docs-clean`, `research`, `analyze`; `refresh` and `critique` predate this block
and already behave this way). Written once in M7; read by each util's spine, which states only
its delta.

## What a util is

- A skill with a spine, run by the user (or suggested by `status`), never a flow step. It runs
  no `state check` and never sets `step` or a gate in `state.yml`.
- It opens with `resolve-paths` ([`paths.md`](./paths.md)); a util that acts on one feature
  adds `state find` from the same opening sequence and stops there.
- Its deterministic part (counting, matching, listing, applying a plan) is a script in
  `scripts/` that prints JSON. `research` has none: its work is the `researcher` agent's. The spine reads the script's output, not the files it scanned,
  wherever the script can answer.

## Nothing changes without a yes

1. The script scans; the main thread drafts a proposal: one row per item, with the action and
   a one-line reason, and the exact text it would write.
2. One question (it names the branch the run will commit to): apply all, adjust (the user names rows to change or skip, in free text), or
   cancel. Adjustments are applied to the proposal and shown once more before writing.
3. Only approved rows are written. Cancel or no approved row: no write, no commit.
4. The write goes through the util's script when it changes a file the script owns, so a file
   that moved since the scan refuses the plan instead of being overwritten.

## Branch

A util never commits on a default branch. Before its first write, for each repo it will
change (the repo holding each root it writes, per `paths.md`), it runs `detect-repo --from
<root>`: when `current_branch` equals `default_branch`, `git -C <root> checkout -b
chore/<util>-<YYYY-MM-DD>` (name taken: add `-2`, `-3`). A dirty tree is fine; the branch
carries it. On any other branch (a feature branch, an earlier chore branch) it stays there.
This holds in the wrapper too. No branch on `git.authority: none`. Pushing and any PR are
the user's; the handoff says so.

## Commit

- One commit per run, in the repo that contains the changed files (`git -C <docs_root>`,
  `git -C <workspace_root>`; two roots in two repos are two commits, per `paths.md`), on the
  branch from "Branch" above. The handoff names that branch.
- Message: `<type>(<util>): <counts>`, where `<type>` is the area touched (`docs` for
  `<docs_root>`, `spec` for spec folders) and `<counts>` lists the non-zero actions in the
  util's own verbs, e.g. `docs(lessons-prune): promote 1, merge 2, delete 3`. No body unless
  the util says so. No AI attribution.
- No commit when `git.authority` is `none` or nothing was written; say which.

## Handoff

Per [`handoff.md`](./handoff.md). `State: <util>` (no feature state). `Next`: the command the
user was running before, or `none`.
