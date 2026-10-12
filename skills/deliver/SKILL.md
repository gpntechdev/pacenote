---
name: deliver
description: >
  Invoke whenever the user asks to deliver, ship, push or open the pull request for a
  verified feature, or runs `/specd:deliver [feature]`; also as the next step after
  `/specd:verify`. It re-runs the project checks, shows you the full change (commits, diff
  stat, review verdict, evidence matrix) for the delivery gate (G5), then goes as far as
  `git.authority` allows: push the branch and open a draft PR or MR whose body says what was
  built, how to verify it and where the spec and record are, in your voice, with no AI
  attribution. Before the first push it offers to squash the `WIP:` task commits into one
  commit carrying the same change summary; you choose per run whether to push and whether to
  open the PR. Re-run after a feedback cycle it pushes to the open PR and refreshes its
  description. It never merges.
---

# Skill: deliver

The last gate and the only step that touches the remote. Everything it pushes already exists
as commits; its own work is the G5 view, the change summary, the optional squash, the push
and the draft PR.

## Gate

`state check --step deliver`: `step` is exactly `deliver` (the tier's previous step is done:
`docs` on full, `review` on quick, `implement` on trivial). G5 is passed here, again on
every re-run after a feedback cycle.

## Inputs

- `resolve-paths`, `detect-repo` (default branch, remote host, remote URL of the code repo;
  of the wrapper too, for its push and links), `state find`, `state check`, `run-checks`,
  `squash-wip` ([`../_shared/paths.md`](../_shared/paths.md): the opening sequence).
- `<spec_root>/<feature>/state.yml` (`tier`, `fix`), `spec.md`, `design.md` (Changes by
  area, Changed contracts, Risks), `review.md`, `tasks.md` (matrix, review-fix phases),
  each when present; `brief.md` (Sources; on trivial, the request itself) and the `origin`
  header of each `<workspace_root>/sources/<feature>-*.md` it lists.
- `<docs_root>/features/<feature>.md` and the `decisions/NNNN-*.md` files it names, when
  `docs` wrote them.
- `<workspace_root>/specd.yml`: `git.authority`, `git.pr_host`, `git.ticket_key`.
- [`../_shared/no-attribution.md`](../_shared/no-attribution.md),
  [`../_shared/gates.md`](../_shared/gates.md), [`../_shared/state-yml.md`](../_shared/state-yml.md).
- `./templates/pr-body.md`, [`./references/change-summary.md`](./references/change-summary.md),
  [`./references/git.md`](./references/git.md).

## Outputs

- `gates.G5`, `pr`, `step: close` in `state.yml`; one commit `spec(<feature>): deliver`.
- The branch on the remote and a draft PR or MR, as far as the user chose within authority.

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature"), `state check --step deliver` per
   `gates.md`. Every git command below runs in `<code_root>`, the repo the PR is for,
   unless it names the wrapper (`git.md`, "Wrapper").
2. **Checks.** `"${CLAUDE_PLUGIN_ROOT}/scripts/run-checks" --from <code_root>`. Red: refuse
   with the failing tail, handoff `Next: /specd:implement <feature>`.
3. **G5 view.** `git -C <code_root> log <default>..HEAD --oneline` (and, when the branch
   has an upstream, `git log @{u}..HEAD --oneline` as "since the last push"), `git diff
   --stat <default>...HEAD`, the last review or PR round's verdict and accepted findings
   from `review.md`, the evidence (full: the matrix summary from `tasks.md`, ACs total, with
   test evidence, with a check, manual, accepted; quick: the last review round's AC table,
   covered / partial / missing counts; trivial: the brief's words and the checks that ran),
   the docs written by `docs` or "none". Uncommitted changes in `<code_root>` or in
   `<workspace_root>`: list them and stop; they are committed by `implement` or by the
   user, never here.
4. **Change summary.** Draft it per `change-summary.md` from the tier's sources and the
   diff stat, print it in full under the G5 view (not a description of it) and write it to
   `<spec_root>/<feature>/change-summary.md`. It is what the squash commit and the PR will
   say; passing G5 approves it, so edits the user asks for happen here.
5. **Squash choice.** When the log holds `WIP:` commits, `git.authority` is not `none` and
   the branch has no upstream: ask one question, **squash** into one commit (show the title
   per `git.md`) or **keep** the commits as they are. Squash: run `squash-wip --dry-run`
   with the summary as `--body-file`, show the subjects it collapses, run it for real, show
   the new log line and the `before` sha as the recovery point. Branch already pushed, or
   authority `none`: no question, one line saying why the `WIP:` commits stay. Then pass G5
   per `gates.md` on the branch as it now is.
6. **How far.** One question, options in this order and only those `git.authority`
   allows (`git.md`): **push + draft PR** (authority `draft_pr`, and `pr` not yet set),
   **push** (≥ `push`), **record only** (G5 stamped, nothing leaves). Default is the first
   listed. `authority: none`: no question, record only. Push per `git.md`. Render
   `./templates/pr-body.md` on every run: title from `spec.md`'s problem line, or the
   brief's words on trivial; the summary from `brief.md` or `spec.md`; what changed from
   the change summary; how to verify from the checks that ran and the evidence shown at G5;
   notes from `review.md`'s accepted findings and `design.md`'s open risks; links per
   `git.md` "Links". `pr` not set and the choice was the draft: open it with the host's CLI,
   run from `<code_root>`. `pr` already set: the push updates the open PR; say so with its
   URL, replace its description per `git.md` "Re-deliver" and never open another. Record
   only, CLI missing or `git.pr_host: none`: print the rendered body in full (the printout
   is the user's copy), then the exact command and the compare URL when something was
   pushed. Delete the rendered body and the summary file.
7. **Record.** `state set gates.G5=now pr=<url or unchanged> step=close`, commit
   `spec(<feature>): deliver` with `git -C <workspace_root>`; when a push was chosen, push
   that repo too so the state commit is on the remote: the same push in embedded mode, the
   wrapper rule of `git.md` "Wrapper" otherwise.
8. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced`: the PR URL.
   `Review`: what the PR body claims; the `before` sha when a squash ran. `Next:
   /specd:close <feature>` once the PR is settled, then merge; second line
   `/specd:feedback <feature>` when comments arrive.

## Anti-patterns

- Any mention of an AI assistant, model or tool in the title, body or commits.
- `--force`, rebasing or merging; the only history rewrite is `squash-wip`, before the
  first push and on the user's choice.
- Pushing before G5, opening a non-draft PR, or a second PR for a feature whose `pr` is set.
- Going further than the user chose this run, whatever `git.authority` would allow.
- Writing the change summary from the commit log or from memory instead of from the design,
  the tasks and the diff.
- Commit messages, task, finding or AC ids, review rounds or command names in the PR body or
  the squash commit; those are the spec folder's business.
