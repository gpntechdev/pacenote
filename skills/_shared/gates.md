# Gate protocol

**Reference-only.** Not a skill. Read by every step of the feature flow; written by nobody.
Approval lives in the feature's `state.yml` (schema: [`state-yml.md`](./state-yml.md)), never
only in the conversation. Gated steps: `specify` G1, `design` G2, `tasks` G3, `implement` G4,
`deliver` and `scaffold` G5. `docs` and `feedback` have no gate; `feedback` is a side entry
that `state check` allows whenever a PR is recorded. Light tiers have fewer gates: on quick,
`specify` writes the task list too and its one gate stamps G1 and G3; trivial has only G4
(the single task's stop) and G5.

## Entering any step

1. Run `"${CLAUDE_PLUGIN_ROOT}/scripts/state" check --file <state.yml> --step <name>` first.
   On `ok: false`, refuse with one line built from its output: `<reason>; run <run_first>
   first.`, adding `or escalate with <escalate>` when the output has that key (the step is
   not in the tier's flow). Then end with the handoff block. Never reason about the order
   yourself.
2. `rerun: true` means `step` is already past this one: the user is revisiting an earlier
   artifact. Say in one line that writing it clears every later gate (`G<n+1>`..`G5`), ask
   whether to continue, and on yes clear those gates with `state set` as the artifact is
   written. Tasks already `done` stay `done`; the user decides what to redo.
3. A gate approved once stays approved until the earlier artifact changes.

## Passing a gate

1. Show the artifact's path and a summary of at most ten lines: what it contains, the
   assumptions it makes, the open questions it leaves. Never paste the file.
2. Ask one question with three options: **approve**, **edit** (the user says what to change),
   **reject** (stop here). Use the assistant's question tool when available, otherwise ask in
   prose and wait.
3. On **approve**: `state set gates.G<n>=now step=next` (the script picks the step after
   this one for the tier; its output names it, and that name is the handoff's `Next`),
   remove the artifact's draft marker, then commit the artifact when `git.authority` is not
   `none`, in the repo that contains it (`git -C <workspace_root>` for spec files, see
   [`paths.md`](./paths.md) "Rules"), then continue.
4. On **edit**: apply the change to the artifact on disk, then go back to step 1.
5. On **reject**: leave `gates.G<n>` empty, set nothing else, and end with the handoff block
   (`Next` names this same command).

## G4 granularity

`flow.gate_granularity` decides where `implement` stops for G4: `task` after every task,
`phase` after the last task of each phase (default), `end` once when no task is left. A task
marked `risk: high` in `tasks.md` stops regardless. G4 is re-stamped at every stop. The
artifact is code, so **edit** is a revision dispatch to the implementer, not a text edit.
At `phase` and `end` the landed tasks are already committed; a rejected stop leaves them
`done` and the run resumable. At `task`, and for a `risk: high` task, the stopped task is
not yet committed: approve commits it, reject leaves it `todo` with its files in the tree.

## Rules

- Chat approval alone is not approval. If the user says "looks good" in prose, still record it
  in `state.yml` before continuing.
- Never approve a gate on the user's behalf, not even for a trivial artifact.
- Gate summaries are the user's whole view of the artifact at that moment; make them earn the
  approval, never pad them.
