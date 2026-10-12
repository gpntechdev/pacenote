# state.yml

**Reference-only.** Not a skill. The per-feature state file at `<spec_root>/<feature>/state.yml`.
Created by the step that opens the feature (`start`, or `scaffold` for the skeleton) and
patched by every later step; read by every step that needs to know where the feature stands.
Flat two-level YAML, like `specd.yml`, so the same parser rules apply. The only writer is
`"${CLAUDE_PLUGIN_ROOT}/scripts/state"`; no skill edits this file with a text tool.

## Default file

`state init` copies this verbatim, then sets `feature`, `tier`, `step`, `retention`, `branch`,
`created` and `updated`.

```yaml
feature: ""                  # folder name under spec_root: slug or ticket key
tier: full                   # trivial | quick | full
step: start                  # start | specify | design | tasks | implement | review | verify
                             # | docs | deliver | close | closed
retention: ""                # distill | clean | keep; empty = project default for the tier
branch: ""                   # git branch created by start; empty when git.authority is none
pr: ""                       # draft PR or MR URL written by deliver
worktree: ""                 # wrapper mode with git.worktrees: ".worktrees/<feature>", relative to
                             # the wrapper root; the feature's spec, docs and code live there

gates:                       # ISO-8601 UTC timestamp when approved, empty otherwise
  G1: ""                     # spec approved
  G2: ""                     # design approved
  G3: ""                     # task list approved
  G4: ""                     # implementation approved (re-stamped at every G4 stop)
  G5: ""                     # diff and review approved for delivery

triage:                      # written by start; escalated by `state escalate`
  proposed: ""               # tier the triage proposed before the user confirmed
  signals: ""                # comma-separated signals that fired, empty when none
  escalated: ""              # "<from>-><to> at <step>" once the tier was raised mid-flow

review:                      # written by review and feedback
  round: 0                   # reviewer rounds completed (PR rounds are counted in review.md)
  open: 0                    # findings or PR comments sent back to implement in the last round

fix:                         # written by fix; empty for every other feature
  symptom: ""                # the bug in one line; set marks the feature as a fix
  repro: ""                  # command that shows the bug (exit != 0 today, 0 once fixed)
  reproduced: ""             # ISO-8601 UTC when repro was seen failing; empty blocks specify and implement

tasks: {}                    # T1: todo | done | skipped; mirrors tasks.md, one key per task

created: ""                  # ISO-8601 UTC
updated: ""                  # ISO-8601 UTC; every writer sets it
```

## The script

```
state init     --file PATH --feature NAME --tier TIER [--retention R] [--step S] [--branch B]
               [--worktree REL]
state get      --file PATH [key ...]        # JSON of the whole file or the named keys
state set      --file PATH key=value ...    # patch in place; `now` = current UTC timestamp;
                                            # `step=next` = the step after the current one
state check    --file PATH --step STEP      # may STEP run? exit 1 with run_first otherwise
                                            # STEP feedback: ok when pr is set and not closed
state escalate --file PATH --to TIER [--signal S]   # raise the tier, rewind step, clear gates
state find     --spec-root DIR [--worktrees DIR] [--feature NAME] [--branch BRANCH]
state list     --spec-root DIR [--worktrees DIR]    # every feature: step, next, gates, tasks
```

`--worktrees DIR` makes `find` and `list` also scan the feature worktrees under `DIR`
(`<wrapper_root>/.worktrees`); each is a workspace of its own and its features are
reported with their `worktree` root. Outside wrapper mode the folder does not exist and the
flag changes nothing.

`set` may add `tasks.<id>` keys that do not exist yet; every other key must already be in
the file. All-or-nothing: a refused key leaves the file untouched.

## Step order per tier

The order lives in the script (`ORDERS`), nowhere in prose. Trivial: start, implement,
deliver, close. Quick: start, specify, implement, review, deliver, close. Full: every step.
`docs` joins a light order only when the feature's `retention` is `distill`. Once `pr` is
set, `next` skips `review` and `docs` (the fix loop). `init` without `--step` and
`set step=next` both read the order, so a skill never names the step after its own: it sets
`step=next` and prints the step the script's output shows as `Next`. `check` refuses a step
outside the tier's flow and names the escalation command.

`escalate` sets `tier`, `triage.escalated`, appends the signal to `triage.signals`, rewinds
`step` to the earliest step the old order lacked (quick→full during implement lands on
`design`; trivial→quick on `specify`) and clears the gates from that step on. Files and
`done` tasks stay: that is what "carried over" means.

## Finding the feature

Every step takes an optional feature argument. Resolve it with `state find` (the full
opening sequence is in [`paths.md`](./paths.md), "Resolving for a feature"), in this order:

1. The argument, when given; it must name an existing folder under `<spec_root>` or under a
   worktree's spec root.
2. The current git branch of `<code_root>` (from `detect-repo`), when exactly one feature's
   `branch` equals it. Inside a feature worktree this is always its feature.
3. The only feature whose `step` is not `closed`, across the main root and the worktrees.
4. Otherwise the script lists the open candidates (worktree ones marked); ask the user which
   one and re-run.

## Rules for readers

- A missing key means its default above. Unknown keys are ignored, never removed.
- A malformed file: stop and show the problem. State is too important to guess.
- `step` names the step that runs next or is in progress, not the last one finished. A step
  sets `step` to its own name when it starts and to the next step's name when it ends.
- Run `state check --step <name>` before anything else; it encodes the step order and the
  gate each step depends on (see [`gates.md`](./gates.md)).

## Rules for writers

- Patch key by key through `state set`; never regenerate the file.
- `tasks` keys are the task ids from `tasks.md` (`T1`, `T2` …). `tasks` adds them when
  `tasks.md` is approved; `implement` flips each to `done` as it lands, `skipped` with a
  reason in `tasks.md`; `review` appends ids for review fixes.
- `updated` is set by the script on every write.
- Owners: `branch`, `worktree`, `triage.proposed`, `triage.signals` by `start`;
  `triage.escalated` by `state escalate` (run from `start --tier`, `specify` or
  `implement`); `pr` by `deliver`; `review.*` by `review` (`review.open` also by
  `feedback`); `fix.*` by `fix`; `worktree` is cleared by `close` when the folder is kept.
  A set `pr` routes the fix loop through `step=next`: `review` and `docs` are skipped.
  Later milestones add keys here and record them in `docs/DECISIONS.md`.
