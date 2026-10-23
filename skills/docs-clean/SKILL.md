---
name: docs-clean
description: >
  Invoke whenever the user asks to clean up, lint, check or tidy the project docs, says
  pointers or links in `<docs_root>` are stale or broken, a docs file is too long, the
  features or decisions index is out of date, onboard drafts were left behind, or old source
  snapshots pile up, or runs `/specd:docs-clean`. A script finds `path:line` pointers that no
  longer resolve or have drifted (and re-anchors them when it can), broken relative links,
  files over their caps, leftover `specd:draft` markers, `features/`, `decisions/` and
  `research/` READMEs out of sync with their folders, and `sources/` snapshots nothing links; it proposes one fix
  per finding, applies only the rows you approve and commits once, never on a default branch.
  Not for `lessons.md` (that is `/specd:lessons-prune`) or for writing new docs (that is
  `/specd:onboard` or `/specd:docs`).
---

# Skill: docs-clean

Keeps `<docs_root>` true to the code and to itself. Code moves and pointers drift; files are
renamed and links break; always-loaded files creep past their caps; indexes miss a row;
snapshots outlive the spec folders that cited them. The script lints and applies; the main
thread judges, drafts trims and asks. A util per [`../_shared/utils.md`](../_shared/utils.md):
no `state check`, nothing written without a yes.

## Inputs

- `resolve-paths` ([`../_shared/paths.md`](../_shared/paths.md)); `detect-repo --from <root>`
  for each repo that will change.
- `<workspace_root>/specd.yml`: `git.authority`.
- `"${CLAUDE_PLUGIN_ROOT}/scripts/docs-clean" scan` output: every finding with its file,
  line, scanned text and, when deterministic, the replacement line.
- Only the docs files a `caps` finding names (to draft the trim), the README of a
  `readmes` finding, and the feature record of a features `missing_row` (its row's cells). Never a file under `<workspace_root>/sources/`: the
  scan gives each snapshot's title, origin and `via`.
- [`./references/proposals.md`](./references/proposals.md) (the action per finding and the
  text rules), and for a trim the template of that file kind (`../onboard/templates/`,
  `../docs/templates/feature.md`, `../_shared/templates/decision.md`), for its contract.

## Outputs

- Line edits in `<docs_root>` and removed `<workspace_root>/sources/*.md`, only through
  `docs-clean apply`; the plan file it consumes is never committed.
- Trimmed files and new READMEs, written with Write in the main thread.
- One commit `docs(docs-clean): <counts>` per repo changed, on a
  `chore/docs-clean-<date>` branch when that repo was on its default branch.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /specd:init first`). Read `git.authority`.
2. **Scan.** `"${CLAUDE_PLUGIN_ROOT}/scripts/docs-clean" scan --docs-root <docs_root>
   --code-root <code_root> --workspace-root <workspace_root> --spec-root <spec_root>`. Print
   `docs-clean: <total> findings — pointers p, links l, caps c, drafts d, readmes r,
   sources s`. Zero: say the docs are clean, end with the handoff.
3. **Read** what step 4 needs and nothing else: each over-cap file in full, the README of
   each README finding, the record of each missing feature row. The other findings carry
   their line.
4. **Propose** per [`./references/proposals.md`](./references/proposals.md). One table, in
   check order, every finding once: `F<n> · <path from docs_root>:<line> · <check> ·
   repoint | relink | unlink | report | trim | leave | sign-off | sync | delete · <reason,
   one line>`. Below it, the exact text each row writes: the new line for a line edit, the
   new row for a sync, the cut list and resulting line count for a trim (the full trimmed
   text on request). A finding on a file being trimmed is folded into its trim and says so.
   Name the commit(s) the run would make.
5. **Ask** one question per `utils.md`, naming the branch: apply all, adjust, cancel.
   Adjust: apply the user's row changes (`F3 delete line`, `F5 sign-off`, `F2 keep`, or
   the text they give), reprint the changed rows, ask again. Cancel: handoff, nothing written.
6. **Branch** per `utils.md` "Branch", for the repo holding `<docs_root>` and, when a
   snapshot is deleted and `sources/` is in another repo, for that repo.
7. **Apply** the line edits and snapshot deletions: Write the plan as JSON to
   `<workspace_root>/.docs-clean-plan.json` (`[{file, action, line, expect, text}]`, one step
   per approved line, `file` absolute, `expect` the scanned `text` of `line`): `replace` for
   repoint, relink and unlink; `delete` for a deleted line, a stale row and a sign-off
   (line 1); `insert` for a new row (`text` goes after `line`); `{file, action: "remove"}`
   for a snapshot. Run `docs-clean apply --docs-root <docs_root> --workspace-root
   <workspace_root> --spec-root <spec_root> --plan <that path>`; it deletes the plan on
   success. Never pass the JSON inline. A refusal means a file moved: re-scan and go back to
   step 4. Skip this step when no row is a line edit or a deletion.
8. **Write** the approved trims and new READMEs with Write, after the apply, each exactly as
   shown in step 4.
9. **Re-scan** (step 2's command) and report what remains: `report` and `leave` rows, and
   anything new. Do not loop on it.
10. **Commit** per `utils.md`: `git -C <docs_root>` add the changed and removed files by
    name, commit `docs(docs-clean): repoint a, relink b, unlink c, trim d, sign-off e,
    sync f, delete g` (non-zero verbs only, in this order; `sync` counts rows, `delete`
    deleted pointer lines and snapshots, the rest findings). When the
    deleted snapshots live in another repo than `<docs_root>`, commit them there as
    `docs(docs-clean): delete g` and leave `delete` out of the first message.
11. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced`: the changed
    files. `Review`: each trim, each `report` and `leave` row still open (with the command
    that owns it), and the branch to push. `State: docs-clean`. `Next: none`, or the
    command the user was running.

## Anti-patterns

- Reading a snapshot under `sources/` to judge it; the header fields from the scan are all
  the proposal needs.
- Guessing a new `path:line` for a pointer the script could not re-anchor; it is reported
  for the user, who knows where the code went.
- Editing docs lines with Edit; line edits go through the plan, so a moved file refuses.
- Removing a draft marker by default; the marker is onboard's resume point and its removal
  is a sign-off the user gives.
- Trimming by cutting the newest or the last lines; a trim keeps facts and pointers and drops
  narration, duplicates and what another doc already says.
- Touching `lessons.md`, `CLAUDE.md` or anything outside `<docs_root>` and `sources/`.
