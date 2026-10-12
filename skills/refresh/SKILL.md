---
name: refresh
description: >
  Invoke whenever the user says a ticket, wiki page or other source behind a feature or a
  docs section has changed, asks to re-fetch, refresh or re-check sources, or runs
  `/specd:refresh [<feature> | <snapshot path>]`. It re-fetches every snapshot of the
  feature by its `origin` (web pages directly, tickets through the intake agent and the MCP
  server), overwrites the changed ones, has the intake agent summarise the diff, and says
  which gate to re-open (re-run `/specd:specify` when the spec was approved against the old
  text). It offers a patch to `brief.md` and applies it only on your yes; it never edits
  `spec.md` and never re-runs triage. Not for taking in a new source; that is
  `/specd:start --from`.
---

# Skill: refresh

Keeps snapshots honest after their origin moves on. The script does the fetch, the
redaction, the diff and the gate arithmetic. The `intake` agent reads the diff, because the
diff is fetched text. The main thread shows the result and decides nothing on the user's
behalf: what the spec does about the change is for the re-opened gate.

## Inputs

- `resolve-paths`, `state find` (the opening sequence in
  [`../_shared/paths.md`](../_shared/paths.md); no `state check`, refresh is not a flow step).
- The argument: a feature, a snapshot path, or nothing (the feature `state find` resolves).
- `<workspace_root>/sources/<feature>-*.md`, header line only; `<spec_root>/<feature>/
  state.yml`; `brief.md` when a patch is offered.
- `<workspace_root>/specd.yml`: `models.cheap`, `git.authority`, `sources.mcp`.
- [`../_shared/sources.md`](../_shared/sources.md) (adapters, dispatching intake),
  [`../start/references/triage.md`](../start/references/triage.md) (escalation signals).

## Outputs

- The changed snapshots, overwritten with `captured` bumped and `redactions` recounted.
- `brief.md` only when the user accepts the patch; never `spec.md`, never `state.yml`.
- One commit `spec(<feature>): refresh sources` in `<workspace_root>` (authority ≠ `none`);
  `docs: refresh sources for <section>` for onboard snapshots.

## Protocol

1. **Resolve.** With a snapshot path, read its header line: `section` names a feature
   folder → that feature; an onboard section → no feature, no state. Otherwise resolve
   the feature per `paths.md` and list `<workspace_root>/sources/<feature>-*.md`. None:
   say `no snapshots for <feature>` and end with the handoff.
2. **Re-fetch** each snapshot by its header's `via`, with `--diff <spec_root>/<feature>/
   source-refresh-<n>.diff` (onboard: `<workspace_root>/sources/.refresh-<n>.diff`) and
   `--state <state.yml>` when there is a feature:
   - `http`: `"${CLAUDE_PLUGIN_ROOT}/scripts/refresh-source" --file <snapshot> ...`.
   - `file`: the same with `--new <origin>` (relative paths from `code_root`).
   - `mcp:*`: dispatch `intake` in `fetch` mode on `origin`. Tell it to write exactly
     `<snapshot minus .md>.new.md` with link cap 0. Then run `refresh-source --new` on that
     file and delete it. `Status: unavailable`: report the reason and skip the snapshot.
   - `paste`: report `pasted; paste the new text to refresh it` and skip. A paste given now
     is written, with the old header as line 1 (so the hook redacts it), to the `.new.md`
     path and refreshed as for `mcp:*`.
   - `login`, `thin` or `error`: report the reason and skip; the old snapshot stays.
3. **Summarise.** For every `changed` result, dispatch one `intake` run in `diff` mode over
   all the diff files, then delete them (never committed). Never read a diff yourself.
4. **Report.** Per snapshot: `changed +a -r`, `unchanged`, or `skipped: <reason>`. Then the
   agent's `Asked` (what changed) and `Flagged`, at most 15 lines. Then the gate:
   - `reopen: G1`: "the spec was approved against the old source: re-open G1 with
     `/specd:specify <feature>`" (re-running it clears the later gates);
   - `reopen: G4`: the same with `/specd:implement <feature>`;
   - empty: the script's `reason`;
   - onboard snapshot: "re-run `/specd:onboard <section>`".

   If the change trips an escalation signal in `triage.md`, name `/specd:start <feature>
   --tier <next tier>`. Triage is not re-run.
5. **Offer the brief patch** (feature only): show the exact lines to change in `brief.md`:
   - the source's paragraph in What was asked, from the agent's answer;
   - new gaps in Not said;
   - Flagged;
   - the captured date in Sources.

   Ask apply / skip. Apply only on yes.
6. **Commit.** `git -C <workspace_root>`: stage the overwritten snapshots and, when
   patched, `brief.md`; commit as in Outputs, no attribution. Nothing changed: no commit.
7. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: what changed
   and the gate. `Next`: the command from step 4, or whatever the user was doing.

## Anti-patterns

- Reading a fetched snapshot or a diff in the main thread; the agent's answer is the input.
- Editing `spec.md`, clearing gates or setting `step` here. Re-opening is the named step's
  job, run by the user.
- Patching `brief.md` before the user says yes, or re-running triage on a changed brief.
- Fetching links found in a changed source; they go to the user as `--from` suggestions.
