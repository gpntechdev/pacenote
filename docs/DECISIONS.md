# Decisions

Running log of decisions that change or refine `docs/PLAN.md`. Newest last. Each entry:
context (why it came up), decision, consequences. The plan stays the source for the design;
this file is the diff history of its judgement calls.

## 2026-09-22 M0: specd.yml schema is an annotated YAML reference

Context: the schema needed a home that both skills and humans read, before any init code exists.
Decision: `skills/_shared/specd-yml.md` holds the default file with a comment per key plus
reader and writer rules; no JSON Schema.
Consequences: one source, copied verbatim by `init`; machine validation of user config, if ever
needed, is a later script reading the same file.

## 2026-09-22 M0: principles text lives in `_shared`, the skill is a protocol spine

Context: PLAN 3.9 lists principles among shared blocks; the skill is also the trigger surface.
Decision: `skills/_shared/principles.md` is canonical; `skills/principles/SKILL.md` is a short
protocol that reads it. Other skills link the shared file, not the skill.
Consequences: one extra file read when the skill fires; no duplicated text.

## 2026-09-22 M0: scripts are stdlib-only Python 3

Context: macOS ships Python 3.9 without PyYAML; the validator and path helper must run anywhere.
Decision: `scripts/*` use the standard library only. Config is read by a flat-key parser that
covers the subset specd.yml uses; full YAML parsing is not needed.
Consequences: `specd.yml` stays flat (two levels, scalar values, simple lists) so the parser
keeps working. A key needing deeper nesting is a decision to revisit here.

## 2026-09-22 M0: path resolution is a script, not prose

Context: every skill resolves `workspace_root`, `code_root`, `docs_root`, `spec_root`.
Decision: `scripts/resolve-paths` prints them as JSON; `skills/_shared/paths.md` documents the
rules and tells skills to run it.
Consequences: skills never reason about folder layout; wrapper and embedded are one code path.

## 2026-09-22 M0: no-attribution is a workspace setting written by init

Context: a plugin-level `settings.json` supports only `agent` and `subagentStatusLine`, so the
plugin cannot switch attribution off for its users.
Decision: `skills/_shared/no-attribution.md` holds the `attribution` snippet `init` writes into
each workspace's `.claude/settings.json`; this repo carries the same snippet for itself.
Consequences: attribution is off only after `init`; deliver enforces the wording rules regardless.

## 2026-09-22 M0: `git.docs_repo` dropped from specd.yml

Context: PLAN 2 says wrapper mode chooses at init whether `docs/` lands in the wrapper or the
code repo. A separate key would duplicate what `paths.docs_root` already says.
Decision: `init` writes `paths.docs_root` to the chosen folder; a skill committing a docs change
picks the repo that contains the path.
Consequences: one key fewer; the repo choice is derived, never stated twice.

## 2026-09-22 M0: marketplace and plugin are both named `specd`

Context: the repo serves itself as a marketplace with one plugin.
Decision: marketplace `specd`, plugin `specd`, install as `specd@specd`; `source: "./"`.
Consequences: a second plugin in this repo would need a `plugins/` subfolder and a rename of
`source`; not planned.

## 2026-09-22 M0: layout folders appear when first used

Context: PLAN 4 lists `agents/` and `hooks/`; git does not track empty folders.
Decision: no placeholder files. `agents/` arrives with the first agent (M1), `hooks/` with the
gate hook (M2). The validator already checks both when present.
Consequences: the tree matches PLAN 4 only after M2; README shows the full layout anyway.

## 2026-09-22 M0: principles auto-invocation stays probabilistic until after M2

Context: Claude Code invokes a skill when the model judges its `description` relevant; nothing
forces it. In a headless test the same small coding request skipped the skill with a descriptive
wording and invoked it with an imperative one ("Invoke first, before any tool call, whenever...,
however small the task"). One sample each, so the wording helps but is not a guarantee.
Decision: keep description-driven invocation for ad-hoc coding requests. Inside the flow the
skills that write code (`implement`, `fix`, `scaffold`) link `_shared/principles.md` in their own
protocol, so the principles load deterministically there. No hook.
Consequences: a request outside the flow may occasionally run without the principles. Revisit
after M2, once the flow has shipped a real feature: if ad-hoc requests miss the skill often
enough to matter, add a `UserPromptSubmit` hook that reminds the model to invoke it, and record
that here.

## 2026-09-22 M1: toolsmith stays in M6; init only names it

Context: the M1 request listed `toolsmith` with the init commands. PLAN 3.5 calls it from init's
handoff, but its substance (allowlist search, quarantine, two-stage audit, `skills.lock`) is M6.
Decision: no `toolsmith` skill in M1. `init`, `onboard` and `scaffold` end their handoff with one
line naming `/specd:toolsmith` as a later step.
Consequences: a fresh workspace has Context7 and nothing else until M6; the handoff line is the
only place to update when the command lands.

## 2026-09-22 M1: secrets guardrail hook ships now, file tools only

Context: PLAN 3.5 lists the guardrail under `init`; the M0 entry above expected `hooks/` to
arrive with the gate hook in M2. The hook is plugin-level, so `init` has nothing to write for it.
Decision: `hooks/hooks.json` registers a `PreToolUse` hook on `Read|Edit|Write|MultiEdit|
NotebookEdit`; `hooks/secrets-guard` denies (exit 2) a fixed list of secret file patterns
(`.env*` minus example files, keys, certificates, credential stores). Bash inspection (`cat
.env`) is out of scope.
Consequences: `hooks/` exists before M2, amending the M0 entry. A leak through Bash is the
trigger to revisit; parsing shell is not worth it before one is observed.

## 2026-09-22 M1: onboard resumes from a draft marker, not a state file

Context: `onboard` must resume after `/clear` from the first unfinished section; files are the
state.
Decision: every onboard template starts with `<!-- specd:draft -->`. A section is unfinished when
its index file is missing or still carries the marker; sign-off removes the marker and commits.
No `onboard.yml`, no key in `specd.yml`.
Consequences: resume is a file check. Project kind is not persisted either: `detect-repo` runs
at the start of `onboard` and `scaffold`, and after scaffold the repo correctly reads as
brownfield.

## 2026-09-22 M1: scaffold builds inline; the reviewer pass arrives with M2

Context: PLAN 3.5 says scaffold runs as a quick-tier feature with a gate and a review; the quick
flow and the `reviewer` agent are M2/M3.
Decision: `scaffold` writes `<spec_root>/scaffold/{tasks.md,state.yml}` (tier `quick`,
`retention: clean`), passes G3 on the task list, builds in the main thread applying
`_shared/principles.md`, proves build/test/lint with at most three repairs per command, passes
G5 on the diff, records `commands.*` and commits. No reviewer in M1.
Consequences: the skeleton gets both gates but no fresh-context review until M2, when
`spec/scaffold/` is a closed quick feature that `close` or `spec-clean` remove like any other.

## 2026-09-22 M1: commit policy for init and onboard; private mode

Context: PLAN fixes git authority for features (up to a draft PR) but not for setup commands.
Decision: `init` commits once (`chore: initialise specd workspace`), `onboard` once per
signed-off section (`docs: onboard <section>`), `scaffold` once at G5. Private mode
(`init-workspace --private`) is the `.git/info/exclude` flag from PLAN 3.1 made concrete:
`.specd/`, `CLAUDE.local.md` and `.claude/settings.local.json` are excluded, `.mcp.json` is
skipped with a `claude mcp add` hint, and `init` does not commit.
Consequences: a normal workspace has a clean tree after each command; a private one never shows
specd files to the team and relies on the user's own MCP setup.

## 2026-09-22 M1: gates, handoff and state.yml are shared blocks from now

Context: AUTHORING 3 names the handoff format and gate protocol as shared blocks; `scaffold` is
the first step with gates and a `state.yml`.
Decision: `_shared/handoff.md` (the closing block), `_shared/gates.md` (show, ask, record in
`state.yml`, refuse when unapproved) and `_shared/state-yml.md` (flat two-level default file:
feature, tier, step, retention, gates G1..G5, tasks, timestamps) exist now. M2 extends
`state.yml` with triage signals and review rounds and records the keys here.
Consequences: every later step links these three files and states only its delta.

## 2026-09-22 M1: init-workspace owns every init file operation; config-set is the only writer

Context: init touches eight artifacts, all mechanical (copy, merge, marker insert), and
`specd.yml` must be patched key by key by both `init` and `config`.
Decision: `scripts/init-workspace` creates or merges all of them idempotently, including the
CLAUDE.md pointer block, and reports created/merged/skipped. `scripts/config-set` patches
`specd.yml` values in place, all-or-nothing, refusing list keys. `init` writes the detected
`commands.*` (marked derived) rather than leaving them empty.
Consequences: skills never edit config or settings files by hand; a bug in either script is
fixed once. Detected commands are visible and correctable in `specd.yml`.

## 2026-09-22 M1: explorer has no Bash; the caller passes the model role

Context: AUTHORING 10 keeps read-only agents without `Write`, `Edit` or `Bash`; AUTHORING 8
forbids model names outside `specd-yml.md`, which rules out `model:` in agent frontmatter.
Decision: `explorer` runs with `Read, Grep, Glob`; every git fact comes from `detect-repo` in
the main thread. `researcher` (`WebSearch`, `WebFetch`, Context7) is included minimal for the
greenfield architecture interview. The calling skill reads `models.<role>` from `specd.yml` and
passes it as the agent's model parameter.
Consequences: agents are portable across projects with different model mappings. If the
runtime ignores the per-call model parameter, the fallback is a validator allowlist for
`model:` lines in `agents/`, to be recorded here.

## 2026-09-22 M1: external pages snapshot to `<workspace_root>/sources/`

Context: onboard lets the user paste or point at wiki pages; PLAN 3.7 gives the snapshot and
refresh util to M5.
Decision: snapshots go to `<workspace_root>/sources/<slug>.md` with a provenance header and
redaction counted; `docs/` links and condenses, never copies. Redaction is a documented rule in
`skills/onboard/references/sources.md` until M5 provides the util.
Consequences: raw material is separated from curated knowledge and is never auto-loaded; M5's
refresh util has a folder to own.

## 2026-09-24 M1: config skill added; scaffolded repos are brownfield by state, not by count

Context: a review of M1 found two gaps. `init`, the CLAUDE.md template and the handoffs sent
users to `/specd:config`, which no milestone had built. And the entry above claiming that a
scaffolded repo "correctly reads as brownfield" was false: a skeleton has two or three source
files, under the `detect-repo` threshold of five, so onboard sections run after scaffold
(conventions, data-models, decisions, which its gate does not require) would have run as
interviews.
Decision: `skills/config` exists as a thin wrapper over `config-set`: show, ask, patch, say
when the value applies, no commit. `detect-repo` reports `scaffolded: true` when
`.specd/spec/scaffold/state.yml` has `step: closed` and then reports `kind: brownfield`
whatever the file count; the count stays the fallback for repos specd did not scaffold.
Consequences: every `/specd:config` reference resolves. Lowering the threshold was rejected
because a tiny real repo would then read as greenfield; the state file is the signal specd
itself wrote. A scaffold still in progress leaves the kind untouched.

## 2026-09-24 M2: branch at start, commit per step; `git.authority` caps deliver

Context: PLAN 3.3 gave `deliver` "branch, atomic commits, push, draft PR", which leaves every
spec file and all code uncommitted until the last step; M1 already commits per step.
Decision: `start` creates the feature branch; `specify`, `design` and `tasks` commit their
artifact after the gate; `implement` commits per task with the message fixed at G3; `deliver`
re-runs checks, passes G5, pushes and opens the draft PR. `git.authority` means: `none`, specd
runs no git write command at all (no branch, no commit); `commit`, branch and local commits,
deliver stops after G5; `push`, plus push; `draft_pr`, plus the PR.
Consequences: resume after `/clear` never loses work and two features never share a tree.
The PLAN 3.3 deliver row is read with this amendment.

## 2026-09-24 M2: tiers are recorded, every feature runs the full flow

Context: triage proposes trivial/quick/full, but the light flows and escalation are M3.
Decision: `start` writes `tier` and `triage.proposed`; the tier sets the default retention
and is shown by `status`; every step runs regardless of tier.
Consequences: a quick feature costs a full flow until M3; the state is already in place for
M3 to branch on.

## 2026-09-24 M2: `scripts/state` owns state.yml; new keys; feature resolution; no gate hook

Context: every step reads and patches `state.yml`, must know whether it may run, and must
find its feature after `/clear` without an argument. PLAN 3.9 and the M0 entry expected a
gate-enforcement hook.
Decision: `scripts/state` (init, get, set, check, find, list) is the only writer; `set` may
add `tasks.<id>` keys and takes `now` as a timestamp. New keys: `branch`, `pr`,
`triage.proposed`, `triage.signals`, `review.round`, `review.open`. Resolution order in
`state find`: argument, then the feature whose `branch` is the current git branch, then the
only open feature, else ask. `state check` encodes the step order and gate prerequisites; a
step may re-run an earlier artifact, which clears every later gate. No hook: a hook cannot
know which feature is active without a "current feature" file, which parallel features (M4)
would break. Amends the M0 entry a second time.
Consequences: skills never reason about order or edit state by hand. Revisit the hook with
worktrees in M4.

## 2026-09-24 M2: sources rules move to `_shared`; the brief is written in the main thread

Context: `start` snapshots files and pastes the same way `onboard` does; PLAN 3.3 says the
brief is written by an agent that treats fetched text as data.
Decision: `skills/_shared/sources.md` and `_shared/templates/source.md` replace the onboard
copies. For local files and pastes the main thread writes the brief: a paste is already in
context, and a file the user named is theirs. The isolating agent arrives with URL and MCP
sources in M5.
Consequences: one set of redaction rules; M5 adds the agent without touching the brief format.

## 2026-09-24 M2: critic hook points are marked comments in the spine

Context: the critic agent is M3, but `specify` and `design` must already have its place.
Decision: each spine carries one protocol step marked `<!-- specd:critic-hook: M3 -->` that
states the M3 behaviour and, until then, prints `critic: not available until M3`. M3 replaces
the marker line, nothing else moves.
Consequences: the user sees where the critic will run; the gate summary is unchanged.

## 2026-09-24 M2: the architect writes `design.md` itself; sections are selected before it runs

Context: AUTHORING 5 says subagents return bounded summaries, never file dumps; a design
draft is a whole file. PLAN 3.3 wants only the sections the feature needs.
Decision: `architect` gets `Write` for exactly one path, `<spec_root>/<feature>/design.md`,
writes the draft there and returns a summary (sections, decisions, open questions,
pointers) of at most 40 lines. The main thread selects the sections from a signal table in
`skills/design/references/sections.md` before dispatching, and the user can veto the
selection. The tier does not change the selection in this milestone.
Consequences: the draft never passes through the conversation; the validator keeps
`architect` out of the read-only set. A second writable path is a new decision.

## 2026-09-24 M2: `run-checks` runs the checks; implement continues after a G4 approval

Context: `implement`, `verify` and `deliver` all run the project checks and must not fill
the context with output. A G4 stop could end the run or let it continue.
Decision: `scripts/run-checks` calls `detect-commands`, runs each detected command in the
repo root and prints JSON with the exit code and the last 40 lines per check. After a G4
approval `implement` continues in the same context with the next task; the implementer's
summaries are small, so the context grows slowly. Every stop is resumable from disk.
Consequences: check output never exceeds a bounded tail; a user who wants a fresh context
rejects the gate (tasks stay `done`) and re-runs the command after `/clear`.

## 2026-09-24 M2: the reviewer reads a diff file; fixes become tasks; three rounds at most

Context: the `reviewer` is read-only (no Bash, M1 validator rule), yet it must see what
changed, including removed lines. Findings the user wants fixed must reach `implement`.
Decision: `review` writes `git diff <default>...HEAD` to `<spec_root>/<feature>/review.diff`,
the agent reads it, and the file is deleted before the commit. Each finding the user marks
`fix` becomes a task in a `Review fixes (round n)` phase of `tasks.md` with a new id and a
`commit:` line; `step` goes back to `implement`. A `missing` AC cannot be accepted. After
three rounds `review` refuses and the user decides by hand.
Consequences: fixes get the same gate, commit and evidence path as any task; the diff is
never committed; the validator keeps `reviewer` read-only.

## 2026-09-24 M2: verify fills the matrix in `tasks.md`; deliver degrades without a forge CLI

Context: PLAN 3.3 says `verify` fills the evidence column and lists no `verify.md`; the PR
step depends on `gh` or `glab`, which a machine may lack.
Decision: evidence lives in the coverage matrix of `tasks.md` (a passing named test, a
green check, or a dated manual note the user gave). `deliver` pushes and, when the host CLI
is missing or `git.pr_host` is `none`, prints the exact command and the compare URL and
stops at `push`; the PR URL, when obtained, is written to `state.yml` as `pr`. `close`
pushes its commit when authority ≥ `push`, so the PR carries the distilled docs.
Consequences: no extra artifact; a manual PR is a documented degradation, not a failure.

## 2026-09-24 M2: decision template moves to `_shared`; no `docs` step in M2

Context: `close` writes decision files with the same template `onboard` uses; the brief
listed no `doc-writer` or `docs` step.
Decision: `skills/_shared/templates/decision.md` is the one template, linked by both.
`close` writes `<docs_root>/features/<feature>.md` and the doc deltas; user-facing docs
beyond that are a later milestone.
Consequences: `onboard` and `close` cannot drift on the decision format.

## 2026-09-24 M2: the real-feature run is the user's; M2 closes on their feedback

Context: PLAN 5 makes M2 done when one real feature ships as a draft PR and resumes after
`/clear`. specd's own skills are not loaded in the session that builds them, and the gates
are the user's to answer.
Decision: the milestone is marked built, not done. The user runs the flow on a real feature
in a repo of their choice with `claude --plugin-dir`, and their findings land here before
M3 starts. The plugin's own verification is script tests and a headless smoke run of
`start`, `status` and `specify` in a scratch repo.
Consequences: PLAN 5 row M2 says "built"; the "done" mark and any protocol fixes follow the
run.

## 2026-09-24 M2: close asks which design decisions are durable

Context: the headless smoke run of the full flow (a one-flag CLI feature) distilled four
decision files, each about that feature's own files. Decisions the architect lists are
alternatives it weighed, not necessarily knowledge the project needs for years.
Decision: `close` lists the `### D<n>` blocks and asks which are durable, with a test in
`skills/close/references/distill.md`: a later feature could reasonably choose otherwise and
would want to know why. The rest become one line each under Notes in
`<docs_root>/features/<feature>.md`.
Consequences: `decisions/` stays small; the design keeps listing every weighed alternative
because tasks and review use them.

## 2026-10-05 M2 feedback: brownfield data-model files hold pointers; large sections run in batches

Context: on a greenfield test project `onboard data-models` wrote one file per domain with
fields and defaults, which is right when no code exists but would turn a large brownfield
repo into a schema dump, and a single explorer pass cannot map thirty domains in 80 lines.
Architecture areas have the same shape.
Decision: brownfield domain files list entities one line each with a `path:line` pointer and
record only relationships and invariants the code does not state; greenfield files keep
fields until the code exists and a refresh replaces them. Domain and area files are capped at
60 lines; past fifteen entities a file names the aggregate roots and points to the folder.
Architecture and data-models run a map pass first; more than five items means the run
writes the index plus draft stubs and later runs fill at most five stubs each, resuming from
the first file still carrying the draft marker.
Consequences: `onboard` may take several runs for one section on a large repo; the section
is complete when no file of it carries the marker. Batching is the same resume mechanism as
before, so no new state.

## 2026-10-05 M2 feedback: design.md Approach and contracts are structured by kind

Context: a real `design.md` (markets feature, 180 lines) had a dense pointer paragraph for
Approach and one bullet list mixing an HTTP call, a DTO, an error class, query keys,
composables, component props and client defaults under API and contracts. Sequences and UX
flows read well; the other two did not.
Decision: Approach has fixed sub-headings: `### Summary` (three sentences, no pointers),
`### Builds on` (pointer bullets), `### Changes by area` (table Area | Files | Change).
API and contracts has one sub-heading per kind, present only when used: External calls
(table), Types (code fence), Module interfaces (fenced signature plus one line of behaviour),
Components (table), Changed contracts (before → after table). Data model gets `### Entities`
(table) and `### Migration`. The cap rises from 200 to 250 lines; the architect keeps table,
fence and one-line-prose shapes and omits empty sub-headings.
Consequences: `tasks` reads the changes table and the contract kinds by name; a design that
needs more prose puts it in a decision's Context or a sequence.

## 2026-10-05 M2 feedback: tasks.md splits into one file per task past 100 lines

Context: a thirteen-task feature produced a 242-line `tasks.md`; the tests blocks make each
task fifteen lines, so the file stops being readable at about six tasks.
Decision: two layouts, chosen by `tasks` before writing and named in the header. Inline
keeps task blocks in `tasks.md`. Split, used when the inline file would pass 100 lines,
keeps `tasks.md` as the index (phases with one index line per task, and the matrix) and
puts each task body in `tasks/T<n>.md` from a task template, at most 60 lines. Readers test
for the `tasks/` folder; `implement` reads the task file before dispatching, `review` adds
fix tasks in the layout in force. The matrix, `state.yml` ids and the G4 phase boundaries
come from `tasks.md` in both layouts.
Consequences: a large feature's task list stays scannable; the implementer still receives
one task verbatim. Converting between layouts after G3 is not supported.

## 2026-10-05 M2 feedback: the split unit is the task, not the file

Context: the entry above split `tasks.md` whenever the whole file would pass 100 lines. The
user's concern was token cost per task, not file length: `implement` reads `tasks.md` on
every run, so one heavy task body is paid for on every task, whereas a dedicated file is
read once, by the run that needs it. A long file of light tasks is fine.
Decision: a task whose body would pass about 100 lines is first questioned (is it one unit?)
and, when it is, externalised to `tasks/T<n>.md` with a single index line in `tasks.md`.
Light tasks stay inline beside it. No layout field; readers recognise an externalised task
by its index line, not by the folder. Supersedes the entry above.
Consequences: `tasks.md` mixes blocks and index lines; `implement` opens a task file only for
the task in hand.

## 2026-10-06 M2 feedback: stack specialisation is per-layer knowledge, not per-layer agents

Context: the user wanted a project-specific implementer (e.g. a `frontend-engineer` that
`toolsmith` generates for a React repo) and asked whether `implementer` could call it.
Claude Code subagents never have the `Agent` tool, so nested dispatch is impossible; and
what differs between a frontend and a backend implementer is the conventions it reads, not
the build-verify-report loop.
Decision: a task carries an optional `layer` (a key of `specd.yml` `layers`); `layers.<name>`
lists project skill files, relative to `code_root`; `implement` and `review` resolve the
task's (or the feature's) layer files to absolute paths and put them in the agent's "read
first" list after `conventions.md`. One layer per task; a task needing two is two tasks.
`toolsmith` (M6) fills `layers` when it installs or generates a skill; until then by hand.
Consequences: one `implementer`, one `reviewer`; the knowledge varies, the agent does not.
`layers` keeps the two-level flat-YAML shape, so no parser or `config-set` change; like
`skills.allowlist` it is a list key and is edited by hand. A per-layer agent with its own
`tools:` (browser or database MCP) is the escalation path if a layer ever needs it, and
would be routed from the same `layers` map; not built.

## 2026-10-06 M2 feedback: WIP task commits, commit after G4 at task granularity, task selection, squash choice at G5

Context: a real run at `flow.gate_granularity: task` committed each task before its G4 stop,
so every change requested at the stop became one more commit and the branch read as noise;
the task commits also carried their final Conventional Commit message while still under
review. The user also wanted to run a subset of the task list (`T1-T3`, `T1, T4, T5`).
Decision: every code commit `implement` makes is `WIP: ` + the task's `commit:` line (the
repair commit too). At `task` granularity, and for a `risk: high` task, the G4 stop comes
first and the commit on approve; a reject leaves the task `todo` with its files uncommitted
in the tree, and the next dispatch of that task is told about them. At `phase` and `end`
tasks commit before the stop as before; a G4 edit is a revision dispatch, landing as a
further `WIP:` commit when the task was already committed. `/specd:implement [feature]
[tasks]` accepts ids and `T<n>-T<m>` ranges, comma or space separated; a selected task whose
dependency is neither `done` nor selected is refused by name, never widened silently; the
run ends after the last selected task with a G4 stop and without the finish step.
`deliver` offers at G5, once, to squash the branch into one Conventional Commit through
`scripts/squash-wip` (soft reset to the merge base, body = the squashed subjects), only when
the branch has no upstream; otherwise the commits stay. Amends the 2026-09-24 "commit per
step" entry (task commits are WIP commits) and the PLAN 3.3 deliver row ("atomic commits" →
WIP commits, optionally squashed). No new `state.yml` or `specd.yml` keys.
Consequences: a feature branch reads as drafts until deliver; the one history rewrite specd
performs is before any push, on the user's choice, and recoverable from the `before` sha the
script prints. In embedded mode the squash folds the `spec(<feature>): …` commits in as well.
A selected run never sets `step=review`; the full command finishes the feature.

## 2026-10-06 M2 feedback: docs before the PR, deliver asks how far, PR feedback loop, close is retention only

Context: `close` wrote the feature record, decision files and doc deltas after the PR was
opened and deleted the spec folder in the same run, so reviewers saw the docs land late and
nothing could go back to the implement loop once comments arrived: no step read PR comments,
`deliver` ended at `step: close` and a re-run would open a second PR. `deliver` also went as
far as `git.authority` allowed without asking per run.
Decision: a `docs` step between `verify` and `deliver` (PLAN 3.3 line 115 already drew it)
takes close's distill protocol; it writes when the effective retention is `distill` and asks
otherwise; the spec folder stays. `deliver` asks once after G5 how far to go (push + draft
PR / push / record only, capped by authority; never a second PR). A `feedback` skill fetches
the PR comments through `scripts/pr-comments` (`gh api` / `glab api`, or pasted text),
resolves each as fix / reply / skip, appends fix tasks under `PR feedback (round n)`, records
`## PR round n` in `review.md`, prints replies for the user to post and sets
`step=implement`. A set `pr` in `state.yml` routes the loop: `implement` then ends at
`verify`, `verify` at `deliver`; the reviewer agent and `docs` are not re-run (available by
hand). `close` is retention only, runs on the branch once the PR is settled and before the
merge, refuses a merged PR, and for `distill` requires the record `docs` wrote. `scripts/
state` gains `docs` in the step order and a `feedback` check (ok when `pr` is set and the
feature is not closed); no new `state.yml` or `specd.yml` keys. Amends the 2026-09-24
git-model entry and PLAN rows 140–142.
Consequences: the PR carries the feature and its docs from the first push; the spec folder
lives until the thread is settled, so fixes keep their spec, tasks and state. Fix commits
after the first push carry their plain message: `implement` drops the `WIP:` prefix once
`pr` is set, since nothing squashes them and they stay in the history. The user runs
`close` before merging; `status` keeps pointing at it. Features whose `state.yml` predates
this entry have no `docs` step recorded: `verify` sets `step=docs` on its next run.

## 2026-10-06 M3: the step order per tier lives in `scripts/state`; `step=next`

Context: M3 makes the tier matter. The order of steps differs per tier, `implement` and
`verify` carried the PR-loop routing in prose, and every skill named the step after its
own, which is wrong as soon as two tiers share a step.
Decision: `scripts/state` holds `ORDERS`: trivial `start, implement, deliver, close`; quick
`start, specify, implement, review, deliver, close`; full every step. `docs` joins a light
order only when the feature's `retention` is `distill` (full keeps it always, with its
skip-by-policy question). `verify` does not run on light tiers: on quick the review's AC
table is the evidence `deliver` shows, trivial has no acceptance criteria. `set` accepts
`step=next`, resolved against the tier's order and skipping `review` and `docs` once `pr`
is set; `init` without `--step` picks the first step after `start`; `list` reports `next`.
`check` refuses a step outside the tier's flow and names the escalation command;
`implement` needs G3 except on trivial. Skills now set `step=next` and print the step the
script reports. Supersedes the 2026-09-24 "every feature runs the full flow" entry.
Consequences: no skill knows what follows it; a new tier or a reordered step is one edit
in the script. Trivial has two gates (G4 from its single task's stop, G5), not the one
PLAN 3.3 drew, because G4 is where a revision can be asked for.

## 2026-10-06 M3: specify-lite is one run, two files, one gate

Context: PLAN 3.3 gives quick "spec and tasks in one short file, one gate". A single file
with a tasks section would make `implement`, `review`, `deliver` and `close` test the tier
before every read.
Decision: on quick, `specify` runs one interview round, re-triages the spec against the
design-section signal table and a five-task cap, drafts `tasks.md` from the `tasks`
template and breakdown rules (one phase plus Verify, matrix with Test filled and Evidence
empty), and passes one G1 question over both files; approve stamps `G1` and `G3` and adds
the task ids. Rules in `skills/specify/references/lite.md`. A re-triage hit proposes
escalation to full before the tasks are drafted.
Consequences: downstream steps are tier-blind; the quick folder has one more file that
`close` removes anyway. A sixth task is an escalation signal, never a longer list.

## 2026-10-06 M3: a trivial feature's task is composed from `brief.md`

Context: PLAN 3.3 says trivial has no spec file and "the request is recorded in
`state.yml`". `start` already writes the request into `brief.md` for every tier, and the
implementer needs a task block to build from.
Decision: no `request` key. `implement` composes `T1` in the main thread from the brief
(goal = the user's words, files = the implementer's choice, done-when = the observable plus
green checks, commit derived from the wording), adds `tasks.T1` to `state.yml` and
dispatches the trivial prompt variant, in which the brief's words stand in for the ACs. The
spec folder holds `brief.md` and `state.yml` only. `deliver` titles the PR from the brief.
Consequences: trivial costs one dispatch, one G4 stop and G5; the brief is the record and
leaves with the folder on `close` (`clean`).

## 2026-10-06 M3: escalation is `state escalate`; what exists is carried over

Context: PLAN 3.3 wants a quick feature that trips a signal to stop and propose escalation,
"carrying over what exists", without saying how.
Decision: `state escalate --to TIER [--signal S]` raises `tier`, writes
`triage.escalated: "<from>-><to> at <step>"` (new key), appends the signal to
`triage.signals`, rewinds `step` to the earliest step the old order lacked (quick→full
during implement lands on `design`, trivial→quick on `specify`, an escalation during
`specify` stays there) and clears the gates from that step on. Every file and every `done`
task stays; `tasks` revises an existing `tasks.md` in place. Proposers: `specify` on quick
(a design signal or more than five tasks), `implement` on trivial and quick (a report naming
a migration, a new dependency, a changed public interface, three modules, or two readings of
the task; the agent's files stay uncommitted). By hand: `/specd:start <feature> --tier
<tier>` on an existing feature; on a new one `--tier` skips the triage scan. Escalation only
goes up; `close` and start over is the way down. `status` shows `quick→full`.
Consequences: a feature under-sized by triage loses nothing; `triage.escalated` is the
signal for tuning the triage table after the week of mixed tasks.

## 2026-10-06 M3: `fix` is a skill; the reproduction gates the spec and the code

Context: PLAN 3.3 says "`fix` is quick with a reproduce-first step" and lists `fix` among
the skills. The reproduce step needs a home and an enforcement point.
Decision: `skills/fix` opens the feature through `start`'s intake, branch and commit steps
(linked, not copied) at tier quick, branch `fix/<slug>`, then localises the symptom with one
explorer run and reproduces it: a test-only implementer dispatch or a command the user
gives, run by the main thread and required to fail for the symptom's reason. New
`state.yml` section `fix`: `symptom` (set marks a fix), `repro` (the command), `reproduced`
(timestamp). `state check` refuses `specify` and `implement` while `reproduced` is empty;
`state list` reports `next: fix` then. The reproduction test is committed `WIP: test(…):
reproduce …`; `specify` makes AC1 `<repro> exits 0` and T1 the fix.
Consequences: no spec and no code before a red reproduction; a bug that does not reproduce
stops at `fix` with the output shown. A command in `fix.repro` cannot contain a double
quote (state.yml rule), so tests are narrowed by name.

## 2026-10-06 M3: the critic runs from one shared block; `critique` prints only

Context: the `<!-- specd:critic-hook: M3 -->` markers in `specify` and `design` are where the
critic goes; PLAN 3.3 wants it at exactly those two points, full tier, at most ten findings
folded into the open questions, plus `critique` on demand.
Decision: `agents/critic.md` (read-only, judgment role) returns one `## Findings` section,
`C<n> · kind · pointer · sentence · resolve: question`, at most ten. `skills/_shared/
critic.md` holds the dispatch prompt (artifact, `project.md`, and `spec.md` for a design)
and the folding rules: `specify` appends `Q<n> … critic C<k>` to Open questions, `design`
appends to Risks, duplicates of existing items are skipped and counted. `flow.critic`:
`gates` runs it on full before G1 and G2; `always` adds quick's G1; `off` never. `/specd:
critique <path>` runs the same agent on any file and prints the findings; it writes nothing,
so an approved artifact is only changed by re-running its step.
Consequences: one agent, one prompt, three callers; the user resolves findings at the gate
and nothing is folded as resolved.

## 2026-10-09 M3 run: the PR body and the feature record are written for their readers

Context: the coin-detail run on `specd-test-green` produced a PR body whose `Changes` were
22 WIP subjects (`fix: make test pass`, `docs: record`), a `Verification` of AC counts and
a `Review` of round numbers and finding ids, and a feature record with a flat file list and
an `AC<n> · evidence:` list. The design's approach summary, UX flow and sequence diagrams
died with the spec folder at `close`. Neither artefact told a reviewer what was built or a
later agent what the feature is.
Decision: `deliver` drafts one change summary per run (`skills/deliver/references/
change-summary.md`): things, not commits, grouped `Added / Changed / Fixed / Removed /
Dependencies / Tests`, drafted from `design.md` Changes by area (quick: `tasks.md`; trivial:
the brief; fix: symptom, cause, change) and confirmed against `git diff --stat`. The same
text is the squash commit body (`squash-wip --body-file`) and the PR's `What changed`. The
PR body is Summary, What changed, How to verify, Notes for reviewers (accepted findings as
facts, open risks), Links (blob links on the branch, source origin URLs, `Refs:`); no ids,
no commit messages, no command names; re-deliver re-renders it and replaces the open PR's
description. The feature record is What it does (+ entry points), User flow and How it
works (the design's diagrams and summary, copied verbatim, AC ids stripped), Behaviour
(ACs rewritten as grouped bullets, no ids or evidence), Where it lives (a table by role),
Interfaces, Decisions, How to verify, Notes; cap 150 lines; `features/README.md` indexes
the records.
Consequences: `git log` and the PR tell the same story; the record is longer but carries the
design's picture, which was the only copy; AC ids and evidence live only in the spec folder
and git history, so a fix reads the behaviour and greps the tests. `deliver` now reads
`design.md` and the source snapshots' `origin` headers.

## 2026-10-09 M4: the wrapper branches per feature; close merges the wrapper branch

Context: PLAN 2 wants a branch per feature in both repos and PLAN 3.1 says the wrapper is
invisible to the client; the brief asked what `deliver` pushes, where the PR goes and what
becomes of the wrapper branch. The wrapper has no reviewers, so a PR there is pointless,
but the spec history of a feature should stay grouped and `docs/` written on the branch
must reach the always-loaded copy on the wrapper's default branch.
Decision: `start` creates the same branch name in the code repo and in the wrapper (from
each repo's current branch, or default branch when a worktree is placed); every spec and
docs commit lands on the wrapper branch. `deliver` pushes the code branch and opens the PR
there; the wrapper branch is pushed only when the wrapper has an `origin` remote and
`git.authority` ≥ `push`, else it stays local and the run says so. `close`, after its
removal commit, merges the wrapper branch into the wrapper's default branch (`--no-ff`),
deletes the local branch and pushes the default branch under the same rule; a conflict
stops the run with the files named. specd never merges the code repo. Without worktrees
the wrapper is sequential like embedded: one feature checked out at a time.
Consequences: the wrapper's default branch holds the complete spec history as merge
commits; a second parallel feature needs worktrees (next entry), because one checkout can
be on one branch. The 2026-09-24 M2 git entry now reads for two repos: "commit" means in
the repo that contains the path (`paths.md`, "Rules"), never per mode.
Amended 2026-10-21 M7: a wrapper may have a team remote and PRs of its own; whether the
wrapper branch gets a draft PR or is merged by `close` is the user's choice
(`git.wrapper_pr`, see that entry).

## 2026-10-09 M4: worktrees are opt-in; a feature worktree is a wrapper worktree with the code worktree inside

Context: parallel features need two checkouts of the code and, with a wrapper branch per
feature, two checkouts of the wrapper too. A worktree of the code repo alone would leave
the spec folder on a wrapper branch that is not checked out.
Decision: `git.worktrees: false` by default in `specd.yml`, wrapper mode only, switched
with `/specd:config git.worktrees=true`; embedded ignores it (the spec folder lives on the
feature branch inside the one checkout, a second checkout would hide it). When on, `start`
runs `scripts/worktree add`, which creates `<wrapper>/.worktrees/<feature>/` as a worktree
of the wrapper repo on the feature branch and, inside it at the code folder's relative
path, a worktree of the code repo on the same branch. The worktree is therefore a complete
wrapper layout; `resolve-paths` from inside it finds its own `specd.yml` first, so
`code_root`, `docs_root` and `spec_root` are the worktree's with no special casing, and
`docs_root` inside the code repo lands in the worktree too. `resolve-paths --feature NAME`
resolves from the worktree when run at the wrapper root; `state find` and `state list`
scan `--worktrees <wrapper_root>/.worktrees` so the root sees every feature; `state.yml`
gains `worktree` (relative to the wrapper root; `start` sets it, `close` clears it on
`keep`). `close` removes both worktrees before the merge. `.worktrees/` is gitignored by
init and by the script. The code worktree is a fresh checkout: `start` tells the user to
install dependencies there before `implement`, naming `<runner> install` when
`detect-commands` reports one; `run-checks` and `detect-commands --from <code_root>`
already resolve the worktree's toplevel and find `specd.yml` upward.
Consequences: the assistant is launched in the wrapper root (name the feature, or let
`state find` ask) or in a feature worktree (one session per feature; the feature resolves
from the cwd by branch). Opt-in keeps the single-feature wrapper free of a dependency
install per feature; the key is one `config` call away.

## 2026-10-09 M4: the gate hook stays out

Context: the 2026-09-24 M2 entry deferred the hook to M4, when a worktree path or the code
repo's branch could identify the feature.
Decision: no gate hook. Every skill runs `state check` before anything else, so the hook
could only guard code written outside a skill; it would cost a process per Edit/Write and
would deny the user's own hand edits on a feature branch before G3. Third and last
amendment of the M0 hook entry; PLAN 3.9 "gate enforcement" is read as `state check`.
Consequences: revisit only on an observed case of code landing before G3 through the
flow; the branch → feature lookup the hook would need exists (`state find --branch`).

## 2026-10-09 M4: wrapper init; docs default to the wrapper; the code repo sits inside

Context: PLAN 3.5 limits the wrapper interview to where `docs/` lands; the assistant's file
tools reach only the folder it runs in.
Decision: `/specd:init --wrapper [<folder|url>]`, or proposed when the current folder has
no source files and exactly one nested git repo (`detect-repo` `nested_repos`, which also
stops counting a nested repo's files as the wrapper's). The code repo must be a folder
directly inside the wrapper: a path outside is refused with the hint to move or clone it
in; a URL is cloned. Detection runs on the code repo; the wrapper's own `detect-repo`
answers only `git`. The interview is the embedded one minus private mode plus the docs
question: wrapper (default; zero files in the client repo) or `<project>/docs` (ships with
the code, rides the feature branch, committed there once by init so the client tree is
clean). `init-workspace --mode wrapper --code NAME [--docs REL]` writes the same files at
the wrapper root plus a `.gitignore` with `NAME/` and `.worktrees/`; the generated
CLAUDE.md gets one line naming the code folder and the launch rule, dropped in embedded
mode. Launching inside the code folder is unsupported: no `specd.yml` is found and the
wrapper's settings do not apply.
Consequences: one `init-workspace` with a layout prefix per mode, embedded output
unchanged byte for byte; the client repo's own CLAUDE.md is still read by Claude Code
when its files are touched, its hooks and settings are not.

## 2026-10-09 M4: built, not done; the real wrapper run is the user's

Context: PLAN 5 makes M4 done when two features run in parallel on a client-style repo with
zero files added to it. As with M2, the plugin's own verification is headless.
Decision: the milestone is marked built. The headless run on a scratch client repo covered
wrapper init (client untouched, PLAN 3.1 layout), two quick features in worktrees carried
through start, specify, implement, review and deliver with `git.authority: commit`, one
driven from inside its worktree with no argument and one from the wrapper root by name,
`status` from the root listing both, `close` removing the worktrees and merging the wrapper
branch, a third feature started with worktrees off (both repos on one branch name), and
the same quick flow in embedded mode with unchanged commits. Not exercised: push and PR
(no remote), `feedback`, `docs` in the code repo, a `close` merge conflict, and a code
repo that needs a dependency install per worktree.
Consequences: the "done" mark follows the user's first wrapper around a real client repo;
the parts to watch are the per-worktree install and the merge at `close`.

## 2026-10-12 M5: adapters follow the input's shape; `sources.mcp` is one flat key; Atlassian first

Context: the `sources: []` list in `specd.yml` described nested items the flat parser
cannot read, and `config-set` refused it. PLAN 3.7 lists adapters per type; the user's
tickets live in Jira and their pages in Confluence.
Decision: the adapter is picked from the input: a bare ticket key, or an `*.atlassian.net`
URL, goes through the MCP server named by `sources.mcp`; any other `http(s)` URL goes
through `scripts/fetch-source`; a path is a file; text is a paste (`_shared/sources.md`).
`sources.mcp: none | atlassian` replaces the list and is patched by `config-set` like any
scalar. The first server is Atlassian's remote MCP (`https://mcp.atlassian.com/v1/mcp`,
OAuth through `/mcp`), installed into `.mcp.json` only on confirmation: one question at
`init`, or `/specd:config sources.mcp=atlassian`, both through `init-workspace --add-mcp
atlassian` (wrapper: the wrapper's file; private mode: skipped with a `claude mcp add`
hint). A ticket's linked Confluence pages and Jira issues are fetched at depth 1, at most
5, each its own snapshot. Links to other sites are listed in the brief and never fetched
on their own, because a URL found in fetched text is not one the user gave. Server
missing, unconnected or unauthorised: ask for a paste and go on; the step never fails.
Consequences: a workspace from before M5 still has `sources: []`; readers treat the key as
`none` and the config skill shows the by-hand replacement. No migration code. The
Atlassian read tool names in `agents/intake.md` are from the server's published list and
are confirmed on the first authorised run; a wrong name degrades to a paste, it does not
fail.

## 2026-10-12 M5: redaction is a script, applied by a hook before any snapshot is saved

Context: the redaction rule was a regex list in prose (`_shared/sources.md`), applied by
whoever wrote the snapshot. An MCP fetch is done by an agent, and an agent without Bash
cannot run a script.
Decision: `scripts/redact` holds the patterns and the header handling; `fetch-source` and
`refresh-source` call it. `hooks/source-guard`, a second PreToolUse hook on `Read|Write`,
runs it on every Write whose content starts with the `specd:source` header, from the main
thread or any agent, and returns `updatedInput` with the redacted content and
`redactions=` set. A spike on Claude Code 2.1.296 confirmed that `updatedInput` rewrites a
Write without a `permissionDecision`, and that hook input carries `agent_type`
(`specd:intake` for the plugin agent). If redaction raises, the hook denies the write. The
URL adapter fetches with a script (urllib and a stdlib HTML-to-text converter), not
WebFetch, so the snapshot is verbatim and no model sees the page before the intake agent.
Consequences: a new hook, as AUTHORING 9 requires an entry for; `secrets-guard` is
unchanged. Redaction is deterministic and counted the same on every pass, because the
count is the number of `[redacted]` markers. An Edit or a Bash write of a snapshot is not
covered; `sources.md` forbids both.

## 2026-10-12 M5: fetched text reaches the main thread only as the intake agent's summary

Context: PLAN 3.3 and 3.6 say intake's fetched content is summarised by an agent that
cannot act on it; DECISIONS 2026-09-24 deferred that agent to M5. The first smoke run
showed that prose is not enough: `specify` opened a fetched snapshot in full in the main
thread, although its Inputs line said not to.
Decision: a new `intake` agent (`researcher` is unchanged and keeps its web tools for M6).
- Tools: `Read`, `Write`, and the Atlassian read tools by exact name. No Bash, Edit,
  WebFetch, WebSearch, Agent, or MCP write tools.
- Three modes, named in the dispatch prompt: `condense` (a snapshot), `fetch` (a ticket or
  page, written as snapshots) and `diff` (a refresh diff).
- It answers in at most 40 lines: `Status`, `Snapshots`, `Asked`, `Not said`, `Flagged`
  (instructions found, quoted in one line each, not followed) and `Not fetched`.
- `source-guard` fences it: its Writes must be `sources/<name>.md` files with a header.
- The guard also denies anyone else a Read of a fetched snapshot (`via` `http` or `mcp:*`)
  past line 1, and any Read of a refresh diff.
- The header now carries `via`. The brief's Sources lines carry it too, so `specify` knows
  what it may open without opening anything.
- The brief gains an optional `## Flagged` section.
- `scripts/validate` gets a `NO_ACT_AGENTS` check: no acting tools, and MCP tools only when
  their names are read verbs.
- Files and pastes stay main-thread reads: they are the user's own text.
Consequences: an injected instruction surfaces as one quoted line in the brief and is
never followed. Bash and Grep on `sources/` are not inspected; this is the same boundary as
the 2026-09-22 secrets entry, revisited on an observed leak. The header line itself (title,
origin) is fetched text that the main thread reads, so it is sanitised to plain attribute
values and the title is capped at 60 characters.

## 2026-10-12 M5: refresh is a thin skill; it names the gate and never re-runs triage

Context: PLAN 3.7 gives snapshots a refresh util; the snapshot must be able to change
without the spec drifting silently or being rewritten behind the user's back.
Decision: `/specd:refresh [<feature> | <snapshot>]`.
- `scripts/refresh-source` does the deterministic part: it re-fetches `http` origins, takes
  `--new` for MCP re-fetches (written by `intake` to `<slug>.new.md`) and for file origins,
  redacts, diffs, overwrites the snapshot only when the body changed, and computes the
  advice from `state.yml`. Quick or full with G1 approved gives `reopen G1` (re-run
  `specify`, which clears the later gates). Trivial with G4 or G5 approved gives
  `reopen G4`.
- `intake` summarises the diff. The diff file lives in the spec folder, is never
  committed, and is deleted after the run.
- A patch to `brief.md` is offered and applied only on a yes; `spec.md` and `state.yml` are
  never touched.
- Triage is not re-run. A change that trips an escalation signal names `start --tier`.
- An onboard snapshot names `/specd:onboard <section>`.
Consequences: a skill rather than a mode of `start`, whose spine sits at 126 of 150 lines.
Refresh is not a flow step and runs no `state check`.

## 2026-10-12 M5: built; smoke-tested headless

Context: PLAN 5 makes M5 done when a ticket becomes an approved spec without copy-paste. As
for M2 to M4, the plugin's own verification is headless (memory: headless smoke testing).
Decision: the milestone is marked built. Headless runs in scratch repos, logged as
`stream-json`:
- `start --from` a public page (RFC 2324) took the snapshot (`via="http"`, `redactions=0`);
  the main thread read only the header and the page text appeared only in the subagent's
  context; specify reached an approved G1 with no paste.
- A seeded local page carried an instruction to `touch` a file and edit `README.md`, plus
  an `api_key`. The instruction landed in the brief's `## Flagged` with no tool call made
  for it; both secrets were redacted (`redactions=2`) and the key appears nowhere in the
  run log.
- A direct request to read that snapshot in full was denied by the hook and fell back to
  the header and the agent.
- After the served page changed, `/specd:refresh` reported `+1 -1`, named G1, offered the
  brief patch and, on "skip", committed only the snapshot; `spec.md` and `brief.md` were
  unchanged.
- A ticket key with `sources.mcp: none` gave a paste request with the config hint. With
  Atlassian installed but `needs-auth`, the main thread saw the status and asked for a
  paste without dispatching `intake`.
- The 50-line paste flow ran triage, tier, branch and commit as before, with the hook
  redacting the token in the paste snapshot.
- Wrapper with worktrees: the snapshot landed in `.worktrees/<feature>/sources/` only, and
  deliver's PR body linked the origin.
Not exercised:
- a live Atlassian fetch (OAuth is interactive), so the MCP tool names and the
  linked-page cap are unverified;
- `intake`'s `unavailable` answer through a real dispatch;
- a login-walled page;
- refresh of an MCP or file origin;
- onboard with a URL.
Consequences: "done" follows the user's first authorised ticket run: `start --from
PROJ-123` on their Jira, then `/specd:refresh` after the ticket changes.

## 2026-10-12 M5: marked done

Context: the build entry above left "done" to the first authorised ticket run.
Decision: the user marked M5 done on the headless smoke run. A live Atlassian fetch is
still unexercised.
Consequences: the Atlassian tool names in `agents/intake.md` and the five-page cap are
checked on the first real ticket, and a mismatch goes here as a fix, not as a reopened
milestone. PLAN section 7 now points to M6.

## 2026-10-12 M6: skills live in the workspace's `.claude/skills/`; private mode keeps them in `.specd/skills/`

Context: PLAN 3.1 puts generated project skills in the wrapper's `.claude/`, and `layers`
paths are relative to `code_root`. The brief asked where installed and generated skills
land in each mode. The user chose in the M6 question round.
Decision: the skill home is derived by `scripts/skill-lock`, never asked or tested by a
skill. Embedded: `<repo>/.claude/skills/<name>/`, committed, and also loaded by Claude
Code. Wrapper: `<wrapper>/.claude/skills/<name>/`, so the client repo gets no files; its
`layers` path is `../.claude/skills/...`. Private (`.specd/` in `.git/info/exclude`):
`<workspace_root>/skills/<name>/`, excluded, reached only through `layers`.
Consequences: a feature worktree carries the wrapper's skills, because they are committed
in the wrapper. In private mode the skills do not auto-load in the main thread; the
implementer and reviewer still read them first.

## 2026-10-12 M6: candidates are GitHub tarballs at a full commit; the quarantine ignores itself

Context: stdlib only (2026-09-22 M0). The quarantine must stay out of git and out of every
folder Claude Code loads skills from. The user chose urllib over `git` in a subprocess.
Decision: `scripts/skill-fetch`.
- `list` resolves a ref to a commit and lists the folders holding a `SKILL.md`, from the
  GitHub tree API. It returns names only, no content.
- `fetch` takes only a 40-hex commit. It downloads `codeload` `tar.gz` and extracts only
  the skill folder into `<workspace_root>/.quarantine/<name>-<sha7>/`. Links, devices,
  absolute paths and `..` are never extracted; they are listed under `links`, and any
  listed link refuses the install. Caps are 300 files and 10 MiB.
- `stage` copies a local folder the same way.
- `clean` empties the quarantine.
- `.quarantine/` holds its own `*` `.gitignore`, so `init` writes nothing new.
- `list` and `fetch` refuse any repo not in `skills.allowlist`. That is the enforcement;
  the researcher's restriction to pinned raw URLs is prompt-level only.
Consequences: GitHub only. Another forge is a new adapter in the script. The researcher
(`mode: skill-search`) ranks candidates from the listed folders and fetches only
`raw.githubusercontent.com/<repo>/<commit>/<folder>/SKILL.md`.

## 2026-10-12 M6: `skills.lock` is flat YAML written by `skill-lock`; the hash covers the installed files

Context: the flat parser (2026-09-22 M0) reads two levels with scalar values. A lock must
pin the source and notice drift.
Decision: `<workspace_root>/skills.lock` has one section per skill. The keys are
`source` (`repo` | `local` | `generated`), `repo`, `path`, `commit`, `sha256`, `dir`
(relative to `workspace_root`), `layer`, `verdict` and `audited`.
- `sha256` hashes the sorted `(file sha256, path)` list of the installed folder.
- `scripts/skill-lock` is the only writer:
  - `install` copies from the quarantine. It refuses a `block` verdict, a source outside
    the quarantine, and an existing unlocked folder (the user's own skill).
  - `record` handles generated skills.
  - `verify` reports `ok | modified | missing` per entry.
  - `where` and `discard` serve generation (entry below).
- Updates (`/specd:toolsmith --update`) follow a table in
  `skills/toolsmith/references/audit.md`:
  - an upstream move is re-fetched at the new commit and re-audited;
  - a modified third-party skill is restored, or re-audited and re-pinned as `local`;
  - a modified generated skill is re-pinned without an audit.
Consequences: `layers` and the lock are separate on purpose. `layers` is what agents
read; the lock is provenance. A skill removed from `layers` keeps its lock section until
its name is installed again.

## 2026-10-12 M6: audit severities, calibrated on `anthropics/skills`; refusals are final

Context: PLAN 3.6 lists the static checks but not what a hit means. The first
calibration run over the 20 folders of `anthropics/skills`@`dbd4588` blocked 7 of them,
mostly on environment-variable names in docs (`$ANTHROPIC_API_KEY`, `process.env.PORT`)
and a decoder call.
Decision: `scripts/audit-static` has two severities.
- `block`:
  - hidden or bidi Unicode;
  - long base64 or hex runs, escape runs, non-asset binaries;
  - a download piped or substituted into a shell;
  - bundled hooks, settings, plugin or MCP manifests, or a `hooks:` frontmatter key;
  - env files, key files, credential stores and environment dumps;
  - symlinks.
- `warn`:
  - URLs and network calls (LICENSE files exempt);
  - bundled scripts;
  - broad `allowed-tools`;
  - a single env-var read;
  - a decoder call;
  - images and fonts.
- Blocking findings sort first, before the 60-item cap. Matches are ASCII-escaped and
  capped at 80 characters, because they reach the main thread.
- The install is refused on any `block`, any extracted link, or a stage-2 `refuse` (an
  unreadable answer counts as `refuse`).
- No override inside specd. A user who still wants the skill installs it by hand, and
  toolsmith does not record it.
- After calibration, 3 of the 20 folders block: `claude-api` (a `curl | sh` line and
  references to `.ssh/id_rsa`, `.env`), `skill-creator` (environment iteration in a
  script) and `web-artifacts-builder` (a bundled `.tar.gz`). 12 warn and 5 are clean,
  `frontend-design` among them.
Consequences: a strict false positive pushes the need to generation, which is the safe
direction. The real-repo signal to watch is how often a wanted skill blocks.

## 2026-10-12 M6: the skill-auditor reads only the quarantine, and the quarantine only through it

Context: PLAN 3.6 says stage two is an agent with read-only tools and no network that
treats content as data. M5 showed that prose alone did not keep the main thread out of a
fetched snapshot. The user chose a hook fence over tool restriction alone.
Decision:
- `agents/skill-auditor.md` has `Read, Grep, Glob` and runs at the judgment role. Its
  answer is shaped like `intake`'s: `Status`, `Purpose`, `Files`, `Flagged` (`override |
  exfiltrate | beyond-purpose | other` · `path:line` · one quoted line · "not followed")
  and `Verdict: pass | refuse`. It refuses on any `override` or `exfiltrate`.
- `hooks/source-guard` gains a fourth rule:
  - a Read under `.quarantine/` is denied to everyone but `skill-auditor`;
  - the auditor may Read nothing outside the quarantine;
  - a tool Write into `.quarantine/` is denied to everyone, because only `skill-fetch`
    fills it.
- `scripts/validate` adds `skill-auditor` to `NO_ACT_AGENTS` (no WebFetch or WebSearch
  means no network) and `specialist` to the read-only set.
- Both stages always run, even when stage one already blocks. The report then shows what
  each stage caught.
Consequences: this is a new fence in an existing hook, as AUTHORING 9 requires an entry
for. Grep and Bash on the quarantine are not inspected, the same boundary as the M5
entry; the auditor's own Grep and Glob are scoped by its prompt. The auditor's quoted
lines are the only fetched text the main thread sees.

## 2026-10-12 M6: generated skills are drafted in `.drafts/` and moved into the home on approval

Context: the first headless run wrote the generated skill straight into
`.claude/skills/`. Claude Code treats that folder as protected, and the write needed an
approval that `-p` could not give. Writing an unapproved draft where skills auto-load was
also wrong on its own terms.
Decision: `skill-lock where` creates an empty `<workspace_root>/.drafts/<name>/`. The
folder holds a `*` `.gitignore`. The main thread writes the draft from
`templates/project-skill.md`; the draft is grounded in an `explorer` map at the cheap role
and cited `researcher`/Context7 facts at the judgment role. `audit-static` runs on the
draft, and a `block` is fixed before the draft is shown. On approval, `skill-lock record
--from <draft>` moves it into the home and pins it as `generated`; `discard` drops it.
Generated skills get no stage-two audit: they are the project's own text, written from
its code.
Consequences: every write into a skill home is a script's (`install`, `record`). The
anti-patterns in the spine forbid writing there directly.

## 2026-10-12 M6: `config-set --add` / `--remove` edit list keys; `layers.<name>` opens on first add

Context: M1 made `config-set` refuse list keys. The 2026-10-06 entry left `layers` and
`skills.allowlist` to be edited by hand until toolsmith.
Decision: `config-set --file F --add key=item ...` appends `- item` under a list key and
skips an item that is already there; `--remove` deletes one. Under the `layers` section a
missing key is created, so a new layer needs no hand edit. Scalars keep `key=value` and
are refused with `--add`. The config skill's line "edited by hand until M6" becomes these
two flags. The flat shape is unchanged: a layer is still a second-level key with a simple
list.
Consequences: toolsmith and `/specd:config` share one writer for lists. Amends the
2026-09-22 M1 config-set entry and the 2026-10-06 layers entry.

## 2026-10-12 M6: one `specialist` agent with four lens files; `flow.specialists: ask | off`

Context: PLAN 3.4 names `security`, `performance`, `accessibility` and `tests` reviewers,
run after the base reviewer in fresh context and routed by the main thread. The user chose
"proposed from the diff, asked" over a fixed list or per-tier automation.
Decision:
- One read-only `agents/specialist.md` (judgment role). The lens checklist and its
  severity scale live in `skills/review/references/specialists/<lens>.md`. Four agent
  files would have repeated the same scope, answer shape and rules (AUTHORING 3).
- `review` step 4: with `flow.specialists: ask` (the default; a missing key means `ask`),
  the main thread proposes lenses from diff signals (`references/specialist-prompt.md`),
  asks once with multi-select, and dispatches one fresh run per picked lens,
  sequentially. Each run gets the base reviewer's findings as settled.
- Findings carry the lens prefixes `SEC`, `PERF`, `A11Y` and `TEST`, with the lens as
  `Ref`, in the same table and resolution loop. A specialist `blocker` makes the round
  `fix first`.
- Round 2 onwards proposes only the lenses whose signal fires on the fix tasks' files.
Consequences: on `off` the review is unchanged. A per-lens agent with its own tools (a
browser for accessibility) stays the escalation path from the 2026-10-06 entry.

## 2026-10-12 M6: the MCP catalog grows to browser and database servers

Context: PLAN 3.8 proposes browser/DevTools for frontend, a database server for backend
and tracker/wiki servers for sources, installed only on confirmation. The reference
`@modelcontextprotocol/server-postgres` is deprecated on npm.
Decision: `init-workspace --add-mcp` adds four servers to its catalog.
- `playwright` (`@playwright/mcp`) is the default browser server.
- `chrome-devtools` (`chrome-devtools-mcp`) is the alternative.
- `dbhub` (`@bytebase/dbhub`) covers PostgreSQL, MySQL, MariaDB, SQL Server, Oracle and
  SQLite. Its connection comes from `env: {DSN: "${DATABASE_URL}"}`, never a literal.
- `atlassian` is unchanged.
- Private mode prints `claude mcp add` for stdio servers too, with the env var expanded
  by the user's shell.
- `skills/toolsmith/references/mcp.md` maps stack signals to servers and states the
  follow-up for each, such as setting `DATABASE_URL` to a development database.
Consequences: the servers run `@latest`, like Context7's URL. Pinning a version is the
user's edit, which the handoff mentions. A stack outside the catalog gets no proposal; a
new server is a script change.

## 2026-10-12 M6: a local folder is a candidate too (`--from`)

Context: the seeded malicious skill had to fail the full install path. It must not be
published to GitHub, and a user may also be handed a skill folder by a colleague.
Decision: `/specd:toolsmith --from <folder>` stages the folder with `skill-fetch stage`
and runs both audit stages, the report and the decision exactly as for a fetched
candidate. On approval it installs with `source: local` and no commit pin.
Consequences: the allowlist governs search and fetch, not a folder the user hands over
themselves; the audit and the approval still apply.

## 2026-10-12 M6: built; smoke-tested headless

Context: PLAN 5 makes M6 done when the audit catches a seeded malicious skill and one
community skill is installed through the pipeline. As for M2 to M5, the plugin's own
verification is headless (memory: headless smoke testing).
Decision: the milestone is marked built. `tests/test-audit` checks every static
category against `tests/fixtures/malicious-skill/` and finds nothing in the prose-only
injection file or the clean fixture. The headless runs, logged as `stream-json`, used a
scratch embedded repo (React 19 `web/`, Express 5 + `pg` `api/`):
- `toolsmith --from` the seeded skill:
  - stage 1 `block` (six blocking findings in five categories, three warn);
  - stage 2 `refuse`, flagging the precedence override, the exfiltration through the
    final answer and PR body, the "do not mention" line, the `.env` read and the hidden
    reversed text;
  - the prose-only `references/style.md` was flagged by stage 2 alone;
  - nothing installed, lock and config untouched, no commit;
  - every quarantine Read came from the `specd:skill-auditor` subagent.
- A direct main-thread Read of a quarantined file was denied by the hook. The injected
  text appears nowhere in that log.
- `toolsmith` on the stack:
  - Needs were derived from the code; there was no architecture overview. The user cut
    them to two.
  - The researcher fetched only pinned raw `SKILL.md` URLs of `anthropics/skills`.
  - `frontend-design` audited `clean`/`pass` and was installed on yes at `dbd4588…`
    with a tree hash, under `layers.frontend`.
  - The backend need had no candidate, so `backend-express` was generated from an
    explorer map and Context7 Express 5 facts: draft, `warn` (doc URLs), approved,
    `source: generated`, `layers.backend`.
  - Of the proposed `playwright` and `dbhub`, `dbhub` was accepted.
  - One `chore(skills): …` commit holds six files. That run found the protected-folder
    issue the drafts entry above fixes.
- `review` on a quick feature with an injectable search endpoint:
  - the base reviewer read both layer skills;
  - all four lenses were proposed with their signals;
  - `accessibility` was picked and returned `A11Y1-3` without repeating the base F6.
Not exercised:
- `--update` against a moved upstream, and the restore and re-pin paths through the skill
  (`skill-lock verify` was checked at script level);
- wrapper and private skill homes through the skill (the private `claude mcp add` hint
  was checked at script level);
- installing a third-party skill with `warn` findings;
- a refusal caused by extracted links;
- more than one lens in a round, and round-2 lens proposals;
- `playwright` and `chrome-devtools` installs, and a live `DATABASE_URL` connection.
Consequences: "done" is the user's call, after a toolsmith run on a real repo. Watch how
often the static stage blocks a wanted skill, and whether generated skills stay grounded
in the code.

## 2026-10-12 M6: candidates are discovered in the skills.sh index; the allowlist stays the boundary

Context: on the user's Flutter test app, toolsmith found nothing and generated three
mobile skills, although `flutter/agent-plugins` (the Flutter org's own repo, BSD-3,
about 30 skills) exists. The allowlist held only `anthropics/skills`, so search never
left it. The user asked for find-skills to find candidates and for the existing pipeline
to do the rest.
Research:
- `find-skills` (vercel-labs/skills) is a prose skill around `npx skills find`. It vets
  by installs (≥1K), source reputation and stars (≥100), then installs with `npx skills
  add <repo@skill> -g -y`. That install follows the branch head and does not audit the
  content.
- `skills find` (skills 1.7.2, `src/find.ts`) is a thin wrapper over
  `GET https://skills.sh/api/search?q=&limit=20[&owner=]`, sorted by installs, printing
  ANSI text.
- skills.sh shows Gen, Socket and Snyk audits on its HTML pages only; there is no API for
  them.
- claudemarketplaces.com is an HTML directory with no API.
Decision:
- `skill-fetch find` calls that same endpoint with stdlib urllib.
  - It groups hits by GitHub repo, marks the allowlisted ones and drops non-GitHub
    sources and archived repos.
  - It adds stars, license and last push for at most 8 other repos.
  - It returns names and numbers only.
  - Shelling out to `npx skills find` would add Node and an unpinned npm package to
    every run and would mean parsing coloured text, for the same results; it would also
    break the stdlib-only rule (2026-09-22 M0).
- toolsmith gains a Discover step (3):
  - one query per need, built from framework plus topic, never code or names;
  - one multi-select question over the repos not yet allowlisted, pre-selected only at
    find-skills' thresholds (≥1K installs, ≥100 stars, a push in the last 12 months);
  - `config-set --add skills.allowlist=<repo>` for each yes;
  - the researcher then ranks only the folders the index hit, falling back to the full
    listing at the pinned commit when a hit names no folder. The index can lag:
    `flutter-managing-state` is still indexed but gone from the repo.
- Fetch, both audit stages, the decision rule and install are unchanged. The report adds
  the skills.sh page as further reading. Installing through `npx skills` is an
  anti-pattern.
- `skills.discovery: skills.sh | off` (default `skills.sh`; a missing key means
  `skills.sh`). With `off`, search stays inside the allowlist. The queries are the only
  thing sent to skills.sh.
- GitHub API calls go anonymous first, then with `GITHUB_TOKEN`/`GH_TOKEN` (sent to
  api.github.com only), then through `gh api`, as the skills CLI does. The smoke run
  exhausted the anonymous 60 requests an hour, and a discovery run with three needs can
  too.
Calibration: `audit-static` over all 31 skills of `flutter/agent-plugins`@`0ef3972`:
15 clean, 16 warn (doc URLs, one bundled script), 0 block.
Headless smoke on a scratch Flutter app (Riverpod 3, go_router):
- Needs were derived from the code.
- Discovery offered six of 35 non-allowlisted repos: `flutter/agent-plugins` (named as
  official), `affaan-m/ecc` and `jeffallan/claude-skills` pre-selected, the other three
  marked low signal or unlicensed.
- With "1 only", the repo was added. Both audit stages ran on `flutter-add-widget-test`
  (clean/pass) and `flutter-setup-declarative-routing` (warn/pass; the auditor flagged a
  `flutter create` step as beyond purpose). The first was installed at `0ef3972…` under
  `layers.mobile` and committed.
- The main thread made no quarantine reads.
- With `skills.discovery=off`, no index call was made and the allowlist-only search found
  nothing, which reproduces the user's original run.
Not exercised: a repo with an expired or missing license chosen by the user; `--owner`;
a token from the environment (the run used the `gh` fallback).
Consequences: amends the "GitHub tarballs" entry. Search is wide and trust is narrow:
the allowlist grows only by the user's yes, and every skill from any repo is still
fetched at a commit and audited. Pre-selection leans on install counts, which skills.sh
computes and which can be gamed; the audit, not the count, decides.

## 2026-10-21 M7: utils share one block; nothing changes without a yes; one commit form

Context: M7 adds five utils (`lessons-prune`, `spec-clean`, `docs-clean`, `research`,
`analyze`) that are not flow steps. `refresh` (2026-10-12 M5) and `critique` already set the
pattern without writing it down: no `state check`, a script for the mechanics, the user
decides. The user picked the commit form in the M7 question round.
Decision: `skills/_shared/utils.md` holds the conventions every util spine links:
- a util is a skill with a spine, never a flow step; no `state check`, never sets `step` or a
  gate; it opens with `resolve-paths`, plus `state find` when it acts on one feature;
- its deterministic part is a script in `scripts/` printing JSON;
- it drafts one proposal (a row per item with action and reason, plus the exact text it
  would write) and asks once: apply all, adjust, cancel; only approved rows are written,
  through the script when the script owns the file, so a file that moved since the scan
  refuses the plan;
- one commit per run, on the checked-out branch, in the repo holding the path, as
  `<type>(<util>): <counts>`: type by area (`docs` for `<docs_root>`, `spec` for spec
  folders), counts in the util's own verbs, e.g. `docs(lessons-prune): promote 1, delete 2`;
  no commit on `git.authority: none` or when nothing was written;
- handoff `State: <util>`.
`runtime-verify` is a flow step (PLAN 3.3) and does not follow this block.
Consequences: later utils state only their delta. The commit lands on whatever branch is
checked out, as `onboard`'s `docs:` commits do; on a feature branch it rides that PR.

## 2026-10-21 M7: lessons-prune is a scan/apply script plus a judging spine; status warns

Context: PLAN 3.1 caps `lessons.md` (`docs.lessons_max_lines`, 80) and gives pruning to a
util. The user chose in the question round that `status` points to it when the file is over
the cap, and that no step handoff does.
Decision:
- `scripts/lessons scan` counts the whole file (header included, since the whole file loads
  every session), parses `YYYY-MM-DD — context — rule` lines with age, lists malformed lines,
  and flags candidate duplicates: rule-word Jaccard ≥ 0.5 after dropping stopwords and cutting
  words to five letters (a crude stem; "commit" and "committing" are one word). At the cap is
  not over.
- `scripts/lessons apply` takes a plan of `{line, expect, action: delete|replace, text}`;
  every `expect` must match the current line and every replacement must be a lesson line,
  else nothing is written. The plan is a file the skill Writes to
  `<workspace_root>/.lessons-plan.json` and the script deletes on success: the first smoke run
  showed that JSON passed inline through a heredoc trips Claude Code's Bash obfuscation check.
- `/specd:lessons-prune` proposes keep, promote (to a `conventions.md` section, or to a
  decision file from the shared template when the rule needs its reason), merge (newest
  date, stricter wording), rewrite (malformed) or delete, per
  `skills/lessons-prune/references/proposals.md`. Promotions are written in the main
  thread; an approved decision drops the draft marker, since the yes is the sign-off. It
  never deletes just to fit: when the proposal leaves the file over the cap it says so and
  lists the five oldest kept lessons.
- `status` runs `lessons scan` and prints `lessons.md has <n>/<max> lines;
  /specd:lessons-prune` when over.
- Gap recorded, not fixed (user's choice): no skill appends lessons today, although the
  `lessons.md` template says "appended by any step the user corrects". The user appends by
  hand until a writer is decided.
Consequences: `lessons.md` is written only by the user and by the script. Duplicate flags
are candidates; the proposal judges meaning.

## 2026-10-21 M7: lessons-prune built; smoke-tested headless

Context: M7's done-when is still open in PLAN; this task's was "an over-cap `lessons.md` in a
scratch repo is brought under the cap, with one lesson promoted and one deleted, all on the
user's answers". As for M2 to M6, the plugin's own verification is headless (memory:
headless smoke testing).
Decision: built. `tests/test-lessons` covers parsing, ages, malformed lines, duplicate pairs,
the cap edge, apply's refusals (stale `expect`, bad replacement, out-of-range and repeated
lines) and the consumed plan file. Headless runs in a scratch embedded repo
(`docs.lessons_max_lines=20`, `git.authority=commit`, 20 seeded lessons: 26 lines, two
duplicate pairs, one lesson already in `conventions.md`, one about a removed module), logged
as `stream-json`:
- `status` warned `lessons.md has 26/20 lines; /specd:lessons-prune`.
- The first proposal covered every line, found both pairs and the lesson already stated in
  `conventions.md`, and drafted rule lines and one decision file. It promoted generously (9
  conventions lines from mostly single lessons), which the adjust round corrects.
- Adjusted answers: one pair promoted to `Git and PR rules`, the money pair merged (newest
  date kept), two deleted, the rest kept. Commit `docs(lessons-prune): promote 1, merge 1,
  delete 2`; the file stood at 21/20, and the run said so and listed the oldest kept lessons.
- A fresh run (re-scan from disk) deleted one more on the user's answer: `delete 1`, 20/20.
  `status` then printed no warning. The plan file was consumed; the tree was clean.
- An earlier run with the decision path: `decisions/0001-…md` written from the template
  with its README row and no draft marker, committed as `promote 2, delete 2`.
Not exercised: `rewrite` of a malformed line through the skill; a refusal of a stale plan
through the skill (script-level only); `git.authority: none`; wrapper mode with `docs_root`
in the code repo; an under-cap run.
Consequences: "done" for M7 is the user's call after Task 6. Watch whether proposals keep
over-promoting single lessons; if they do, tighten `proposals.md` to require recurrence.

## 2026-10-21 M7: spec-clean lists by script, distills inline, branches off the default branch

Context: PLAN 3.1 says `status` warns about kept folders older than `flow.keep_days` and
`spec-clean` distills or deletes them in batch. A kept folder reaches the default branch when
its PR merges (embedded) or when `close` merges the wrapper branch, and from then on neither
`close` (it refuses a merged PR) nor `docs` (it refuses a closed feature) runs for it. The user
chose in the question round where the commit goes and what distill means.
Decision:
- `scripts/spec-clean scan` reads the features through `state list` (one parser) and reports
  closed features as `old` (older than `--days` by the date of `updated`, with `record` when
  `<docs_root>/features/<feature>.md` exists), `fresh`, `blocked` (still inside a worktree:
  `close` stopped, so it goes back to `close`) and `errors`. At exactly `keep_days` a folder is
  fresh, matching the lessons cap rule. `status` now calls it instead of computing ages itself.
- `scripts/spec-clean apply` takes `[{feature, updated}]` from a plan file, refuses the whole
  plan when a folder is missing, reopened, in a worktree or has a changed `updated`, removes
  the folders from the filesystem only and consumes the plan. No git command, so
  `git.authority: none` holds; the skill stages with `git add -A --`.
- `/specd:spec-clean` proposes per folder `delete` (default when the record exists), `distill`
  (default for a full-tier folder without a record) or `skip` (`delete` is the default for a
  record-less trivial or quick folder: their policy never wrote one), with the design's
  `### D<n>` blocks judged decision or notes in the same table, so one question covers it.
- Distill runs `docs`' write protocol inline, per `skills/spec-clean/references/distill.md`:
  the record and its README row (inserted by date), the approved decisions. No architecture or
  data-model deltas, since the code has moved on; planned paths are checked against the
  current tree and missing ones are dropped and counted in Notes. `Shipped` is the `updated`
  date and an empty `pr` reads `unknown`.
- Branch (user's choice): commit on the checked-out branch, except when a changed repo is on
  its default branch (`detect-repo` `default_branch`); then `chore/spec-clean-<date>` is
  created first. This holds for every repo touched, the wrapper included. No branch on
  `git.authority: none`.
- Commit per `utils.md`: `spec(spec-clean): distill d, delete c` in the repo holding the spec
  root (docs files included when the same repo holds them; each removed folder counts once),
  `docs(spec-clean): distill d` in a separate docs repo.
Consequences: the util's commit never lands on a default branch, so a team that protects it
gets a branch to push and review. The rule became every util's (entry below). The user also
corrected a premise here: a wrapper has its own branches and may have a team remote; that
is settled in the `git.wrapper_pr` entry below.

## 2026-10-21 M7: spec-clean built; smoke-tested headless

Context: this task's done-when was "in a scratch repo with three kept features (one fresh, one
old with a record, one old without), the old ones are distilled or deleted on the user's
choice, the fresh one is untouched, and `status` no longer warns". As for M2 to M6, the
plugin's own verification is headless (memory: headless smoke testing).
Decision: built. `tests/test-spec-clean` covers the age split and its edge, `--days`, record
detection, unreadable state and a missing date, a closed feature inside a worktree, removal
with the plan consumed, and every apply refusal (changed `updated`, reopened, missing, bad and
repeated names, empty plan). Headless runs in a scratch embedded repo on `main`
(`git.authority=commit`, `keep_days` 30), logged as `stream-json`:
- `status` warned `old-bare kept for 93 days`, `old-recorded kept for 81 days`, then
  `/specd:spec-clean`.
- The proposal: `old-bare` distill (full, no record), `old-recorded` delete (record exists),
  `fresh-one` reported as younger and left out; D1 judged decision, D2 notes; the branch named.
- On "apply all": `chore/spec-clean-2026-10-21` was created before any write; the record (two
  planned paths that no longer exist dropped and noted), its README row, `decisions/0001-…` and
  a new decisions README were written; `apply` removed both folders; one commit `spec(spec-clean):
  distill 1, delete 1`; `fresh-one` untouched. The run also noticed that the current code no
  longer does what the spec said and flagged it in Review.
- `status` afterwards: only `fresh-one`, no warning.
- With `git.authority=none`, on the chore branch, two more old folders: the adjust round
  (`old-full2 delete, old-quick skip`) was reprinted and asked again; apply removed one folder,
  no branch, no commit, the deletion left unstaged.
Not exercised: wrapper mode (wrapper on its default branch, `docs_root` in the code repo, two
commits); a `blocked` row and a stale-plan refusal through the skill (script-level only); a
distill with a `review.md` or sequences to copy; a name collision on the chore branch.
Consequences: "done" for M7 is the user's call after Task 6. Watch whether inline distills of
old folders write records worth keeping, or mostly drift notes; if the latter, `delete` should
become the default for every tier.

## 2026-10-21 M7: a wrapper PR is the user's choice (`git.wrapper_pr`)

Context: the 2026-10-09 M4 entry made `close` merge the wrapper branch locally because "the
wrapper has no reviewers, so a PR there is pointless". The user corrected this: a wrapper has
its own branches and may have a remote, used to share the work with a team, and then spec
and docs changes deserve review too. Equally, a single user's wrapper may have no remote at
all. It is the user's call.
Decision: `git.wrapper_pr: false | true` in `specd.yml` (wrapper only; a missing key means
`false`, a file from before M7 adds the line by hand, since `config-set` refuses unknown
keys). `false` keeps the M4 behaviour. `true`:
- `deliver`, when the user chose push + draft PR and the wrapper branch was pushed (it has an
  `origin` and authority allows), opens a draft PR in the wrapper with the CLI of the
  wrapper's own `remote_host`, base its default branch, titled like the code PR, body one line
  linking the code PR. A re-deliver that finds one open says so; the URL is printed, not
  stored, so `state.yml` keeps one `pr` (the code PR's). CLI missing: the command and the
  compare URL are printed.
- `close` still removes the worktree and pushes its removal commit, but leaves the merge to
  the wrapper PR. Without an `origin` no wrapper PR can exist, so `close` says so and merges
  locally as before.
- `init`'s wrapper handoff names the key; `git.md` "Wrapper" holds the rules.
Consequences: amends the 2026-10-09 M4 entry and PLAN 3.1. With `true` the user merges two
PRs per feature, code and wrapper, in either order; the wrapper's default branch gets the
spec history only when its PR merges. Not smoke-tested: a wrapper with a remote and the
draft PR path.

## 2026-10-21 M7: utils never commit on a default branch

Context: the spec-clean question round set "commit wherever you are, except the default
branch" for that util; the user then made it the rule for every util. `utils.md` said a util
commits "on the branch that is checked out", which on `main` means a direct commit.
Decision: `utils.md` gains a "Branch" section: before its first write, for each repo it will
change, a util runs `detect-repo --from <root>` and, when `current_branch` equals
`default_branch`, creates `chore/<util>-<YYYY-MM-DD>` (`-2`, `-3` when taken); on any other
branch it stays; the wrapper is no exception; no branch on `git.authority: none`; pushing
and any PR are the user's. The proposal question names the branch. `spec-clean`,
`lessons-prune` (a new step 6) and `refresh` link it; `critique` writes nothing.
Consequences: amends the 2026-10-21 utils entry ("on the checked-out branch"). A util run on a
feature branch still rides that feature's PR. `lessons-prune` and `refresh` were not re-run
headless after this change; the rule is the one `spec-clean`'s smoke run exercised.

## 2026-10-22 M7: docs-clean is a six-check lint script plus a fixing spine

Context: PLAN names `docs-clean` without a definition. `<docs_root>` drifts in ways no step
notices: code moves under `path:line` pointers, files are renamed under links, always-loaded
files grow, onboard drafts are abandoned, `docs` and `onboard` miss an index row, and
snapshots outlive the spec folders that cited them. The user chose the scope, the pointer
fix, the trim and the status behaviour in the question round.
Decision:
- `scripts/docs-clean scan` reads every `*.md` under `<docs_root>` (fenced blocks skipped for
  pointers and links) and reports six checks: `pointers` (`missing`, `out_of_range`,
  `drifted`), `links` (broken relative), `caps`, `drafts` (line 1 is the marker, with the
  onboard section), `readmes` (`missing_row`, `stale_row`, `no_readme` for `features/` and
  `decisions/`) and `sources` (`<workspace_root>/sources/*.md` that no `*.md` under
  `<docs_root>` or `<spec_root>` mentions as `sources/<name>`; only the header line is read).
  A link on a row already reported stale is not reported again.
- Pointers (user's choice: the script re-anchors, the rest is reported, no agent): the
  identifier is the last backticked non-path token before the pointer, else a leading
  `Name —` / `| Name |`; it must appear as a whole word on the pointed line or range. When it
  does not, its hits in the file narrow to definition lines (`class`, `def`, `function`,
  `type`, `table`, …); one hit gives the replacement line, a range keeping its length. No
  identifier means existence and range only, so prose pointers never false-alarm as drift.
- Caps, whole file, at the cap is fine: `project.md` 100, `conventions.md` 80, area and
  domain files 60, feature records 150, decision files 40. `lessons.md` is lessons-prune's.
- `scripts/docs-clean apply` takes `[{file, action, line, expect, text}]` (`replace`,
  `delete`, `insert` after a line, `remove` for an unlinked snapshot), refuses the whole plan
  on any stale `expect`, a path outside `<docs_root>` and `sources/`, or a snapshot linked
  again, rewrites each file once against the scanned numbering, and consumes the plan.
- `/specd:docs-clean` proposes one action per finding per
  `skills/docs-clean/references/proposals.md`: repoint, relink, unlink, report, trim (user's
  choice: a drafted trim to approve, by the template's contract, folding that file's other
  findings in), leave (a draft marker; sign-off only on the user's word, since the marker is
  onboard's resume point), sync (README rows), delete (snapshots; a pasted one cannot be
  fetched again, which the reason says).
- Commit `docs(docs-clean): repoint a, relink b, unlink c, trim d, sign-off e, sync f,
  delete g` in the repo holding `<docs_root>`; snapshots in another repo (wrapper with docs
  in the code repo) get their own `docs(docs-clean): delete g` there.
- Manual only (user's choice): `status` does not run it.
Consequences: the docs get a linter without a new agent. Drift detection is a name match,
so a pointer whose name line changed meaning but kept the name passes; the scan finds
broken structure, not wrong prose.

## 2026-10-22 M7: docs-clean built; smoke-tested headless

Context: this task's done-when was "a seeded scratch `docs/` with one hit per check is
reported, and the approved fixes land in one `docs:` commit". As for M2 to M6, the plugin's
own verification is headless (memory: headless smoke testing).
Decision: built. `tests/test-docs-clean` covers each check and its controls (fenced
pointers, prose pointers without a name, external and anchored links, the cap edge,
`lessons.md` excluded, both README row forms, a snapshot linked only from a spec folder, a
`.new.md`), re-anchoring by definition, range shift and an ambiguous name, and every apply
refusal plus several inserts at one line and the consumed plan. Headless runs in a scratch
embedded repo on `main` (`git.authority=commit`), seeded with a drifted and a missing
pointer, a moved link target, `project.md` at 110 lines, a draft marker on
`data-models/README.md`, a feature without a row, a decision row without a file, and one
unlinked plus one linked snapshot, logged as `stream-json`:
- The scan reported all eight; the proposal gave repoint, report, relink, trim (the Notes
  section, 110 → 5 lines, grounded: `project.md` is in context through CLAUDE.md), leave,
  sync, sync, delete, and named `chore/docs-clean-2026-10-22`.
- Adjust round (`F2 delete line`, `F5 sign-off`) was reprinted and asked again; "apply all"
  created the branch, applied one plan through the script, wrote the trim, re-scanned to zero
  and committed `docs(docs-clean): repoint 1, delete 2, relink 1, trim 1, sign-off 1, sync 2`.
- No Read of a `sources/` file in any run.
- The first apply read the script's source to learn the plan format, and the verb order
  varied; the spine now names the action per row and the order. A second run from the same
  seed applied without reading the script and committed `repoint 1, relink 1, trim 1, sync 2,
  delete 2`, leaving the draft marker as `leave`.
Not exercised: a `no_readme` creation, a trim of a feature record or decision, a stale-plan
refusal through the skill (script-level only), `git.authority: none`, wrapper mode with the
snapshots and the docs in two repos.
Consequences: "done" for M7 is the user's call after Task 6. Watch whether trims of real
files keep facts; if they cut too much, make `report` the default for caps.

## 2026-10-23 M7: research is a dispatching spine; the result goes where you choose per run; specify and design may offer it

Context: PLAN names `research` without a definition. The `researcher` agent already exists
(onboard, toolsmith), each caller with its own prompt. The user chose in the question round
where the result goes and whether steps may call it.
Decision:
- `/specd:research "<question>" [--feature <name>]` splits the input into at most three
  questions, dispatches one `researcher` each at `models.judgment` (Context7 first, the stack
  line from `project.md` as constraints), and prints the two sections as returned. The main
  thread never calls WebSearch, WebFetch or Context7; the agent is the only reader of
  fetched pages, as `intake` is for sources.
- Where it goes (user's choice: ask per run): one question naming the branch, attach to the
  feature `state find` resolves (open features only; a refusal means none, not a stop), a
  docs note, or don't save. Attach appends `## <date> — <question>` sections to
  `<spec_root>/<feature>/research.md`, which lives and dies with the spec folder. A note is
  `<docs_root>/research/<date>-<slug>.md` from `skills/research/templates/note.md` plus a row
  in `research/README.md`, newest last; a newer answer is a new note, never a refresh.
- Commits per `utils.md`: `spec(research): attach <n>` or `docs(research): note <n>`; never
  on a default branch.
- No script (judgement call): nothing is counted, matched or applied from a plan; the work
  is the agent's, and the slug, date and row are written inline, as spec-clean's distill
  writes rows. `utils.md` says so.
- `skills/_shared/research.md` holds the prompt, the rules and both write formats, for
  three readers: `research`, `specify`, `design`. `onboard` and `toolsmith` keep their own
  prompts (stack options, skill search, library facts), unchanged.
- Steps (user's choice): `specify` (interview.md "Research") and `design` (interview step)
  may offer "research it" for an open question that is an external fact, on the user's yes,
  at most three per run; the answer is appended to `research.md`, folded into the open
  question or decision with its URL and date, and rides the step's commit. Both read
  `research.md` when present; design passes it to the architect.
- `docs-clean` covers the new folder: the `readmes` check includes `research/` (rows keyed
  by the note's stem) and research notes are capped at 60 lines.
Consequences: a new `<docs_root>/research/` folder, created only on a user's choice. What
must outlive a feature still becomes a decision through `design` or `docs`; a research note
is evidence with a date, not a decision.

## 2026-10-23 M7: research built; smoke-tested headless

Context: this task's done-when was "one question answered with dated citations, written
where the user chose, and nothing in the main thread fetched pages itself". As for M2 to M6,
the plugin's own verification is headless (memory: headless smoke testing).
Decision: built. Headless runs in a scratch embedded repo on `main` (`git.authority=commit`,
FastAPI 0.115 / Pydantic 2.9 stack line in `project.md`, Context7 in `.mcp.json`), logged as
`stream-json`, with WebSearch, WebFetch and Context7 allowed to every thread:
- One Pydantic question with no feature: the researcher used Context7 then pinned 2.9.2 raw
  docs, returned six dated findings with URLs and two Not found lines; the question offered
  note or don't save (no feature to attach). "Save a docs note" created
  `chore/research-2026-10-23`, the note and a new `research/README.md`, one commit
  `docs(research): note 1`; `docs-clean scan` afterwards: zero findings.
- On a started full-tier feature (`feat/rate-limit`): a two-part input was split into two
  questions, two researchers ran in parallel; "attach both" appended two sections to
  `research.md` on the feature branch, commit `spec(research): attach 2`.
- `specify rate-limit` read `research.md`, cited its findings in two open questions, and
  offered research for the multi-worker question; on yes it dispatched one researcher,
  appended a third section, and folded the answer into Q4 with its date, uncommitted until G1.
- Across the four runs, 26 WebFetch, WebSearch and Context7 calls, every one from the
  researcher subagent (`parent_tool_use_id` set); none from the main thread.
Not exercised: the `design` offer and the architect reading `research.md`; specify through
G1 (the commit carrying `research.md`); "don't save"; a repeated question naming an earlier
note; `git.authority: none`; wrapper mode with `docs_root` in the code repo; a `no_readme`
creation for `research/` through docs-clean.
Consequences: "done" for M7 is the user's call after Task 6. Watch whether steps offer
research for choices rather than facts (specify offered it for a scope question that a
fact informed); if that becomes noise, tighten `research.md` "When".

## 2026-10-23 M7: analyze is two read-only utils; a script counts, an agent judges

Context: PLAN names `analyze` without a definition, and two readings fit: cross-artifact
consistency (spec-kit's `/analyze`) and codebase analysis. The user chose both in the
question round, `analyze` manual only (the `tasks` step and G3 unchanged), and a new agent
for the checks that need reading.
Decision:
- `/specd:analyze [feature]` checks that `spec.md`, `design.md` and `tasks.md` agree, at any
  step once `tasks.md` exists. `scripts/analyze scan --feature-dir` parses the ACs, the
  inline tasks and index lines (with their `tasks/T<n>.md`), the matrix, the decisions and
  the `Changes by area` paths, and reports `ac_uncovered`, `ac_no_row`, `row_unknown_ac`,
  `row_task_mismatch`, `task_no_ac`, `unknown_ac`, `bad_via` and `area_no_task`, each with
  `file:line`. Finding ids from review and feedback (`F3`, `C2`, `SEC1`) count as covered;
  `covers: all` only in the last phase. The D<n> no task names by id are candidates, not
  findings.
- `agents/analyst.md` (read-only, judgment role) reads only those artifacts, takes the
  script's findings as settled and the candidates as leads, and returns at most ten
  `A<n> · decision|term|conflict · <file:line> · … · resolve:` findings. The critic stays a
  one-artifact judge (2026-10-06 M3); the two never share a run.
- `/specd:analyze-codebase [path]` maps where the code is hard to change.
  `scripts/analyze-codebase scan` ranks hotspots (commits since `--since` times lines), maps
  imports parsed by regex (Python, JS/TS relative, Go under `go.mod`, Java/Kotlin, PHP, Ruby,
  Rust) to modules cut at `--depth` 2 with fan-in, fan-out and cycles (strongly connected
  components, with the import lines that close them), and lists source files no test names
  by stem. An import resolves only to exactly one tracked file, so the graph is a lower
  bound; unparsed languages are listed. One `explorer` at the cheap role explains the top
  five hotspots and the cycles.
- Both print and write nothing (judgement call): `utils.md` now says a read-only util
  (`analyze`, `analyze-codebase`, `critique`) has no proposal round, branch or commit, and
  its `Next` names the step that owns a fix (`tasks`, `design`, `specify` for analyze).
Consequences: the critic and the analyst split one artifact's holes from the gaps between
artifacts. `tasks` step 3 keeps its own prose check of the matrix before G3; the script
could replace it later if G3 keeps missing gaps. `analyze-codebase` does not write
`architecture/`; a contradiction with the overview points at `/specd:onboard architecture`.

## 2026-10-23 M7: analyze and analyze-codebase built; smoke-tested headless

Context: this task's done-when for `analyze` was "a scratch feature with one seeded gap of
each kind gets a report that names each gap with `path:line`, and no file changes"; for
`analyze-codebase` it was set here: a seeded hotspot, cycle and untested file all appear,
and no file changes. As for M2 to M6, the plugin's own verification is headless (memory:
headless smoke testing).
Decision: built. `tests/test-analyze` covers every kind and its controls (`all` in Verify,
`via`, finding ids, index lines with and without their file, folder and suffix path
matches, quick without a design, the refusals). `tests/test-analyze-codebase` builds a git
repo with churn, a Python module cycle, a relative TS import and test files by two naming
conventions, and covers skipped folders, `--path`, `--depth`, `--top`, empty files and a
non-repo. Headless runs in a scratch embedded repo (`app/orders` ↔ `app/billing` cycle,
four extra commits on `invoice.py`), logged as `stream-json`:
- `/specd:analyze export` on a full-tier feature seeded with AC4 without a task, T2 with
  `covers: none`, D2 (stream rows) that T1 contradicts by building the list, and "export
  file" in the spec against "report" in the tasks: S1–S3 for the first two, A1 `decision`
  (no task builds D2, T1 builds the rejected alternative) and A2 `term`, every row with
  `path:line`, owners `/specd:tasks`. The three artifacts were read only by the
  `specd:analyst` subagent; file hashes and `git status` unchanged.
- `/specd:analyze-codebase`: the cycle with both closing import lines, `invoice.py` as top
  hotspot and first test gap, `model.py` covered by `test_model.py`; the explorer read only
  the named files and added that `test_model.py` holds no test function. No file changed.
  The run listed empty `__init__.py` files as hotspots and its first scan was blocked on a
  `$PWD` argument; the script now drops empty files and the spine asks for absolute paths.
Not exercised: a quick feature (no design) and a trivial one through the skill
(script-level only); wrapper mode; a repo past a few hundred files (timing); import
resolution for Go, Java/Kotlin, PHP, Ruby and Rust (no test or run covers it); a malformed analyst answer.
Consequences: "done" for M7 is the user's call after Task 6. Watch whether the analyst
flags terms that are harmless synonyms; if so, require that the two names lead to two
readings of an AC or task.

## 2026-10-23 M7: runtime-verify is a full-tier step switched on per feature; a script for HTTP, an agent for the browser

Context: PLAN 3.3 draws `[runtime-verify]` between `verify` and `docs` and gives it "browser
MCP / HTTP" without saying when it runs, how the app is started, or what counts as
evidence. It is a flow step, not a util (2026-10-21 utils entry). The user chose in the
question round: full tier only, a `flow.*` key plus a per-feature yes, `commands.serve`
asked once, a stdlib script for HTTP, an agent for the browser, evidence in the matrix and
in a `runtime.md`.
Decision:
- Order: `scripts/state` keeps `runtime-verify` in `STEPS` but out of `ORDERS["full"]`;
  `order_for` inserts it after `verify` when `state.yml` has `runtime_verify: on`, as `docs`
  joins a light order on `distill`. Quick and trivial never run it (quick has no verify).
  It is not in `PR_SKIPS`: a PR fix loop that turned it on re-runs it, since the fixed
  behaviour is what the reviewers asked about. `state check` refuses it when off and names
  the step that is next.
- New `state.yml` key `runtime_verify: "" | on | off`; `state set` may add it to a file that
  predates it (inserted before `created`), and `step=next` in the same call reads the new
  value.
- Switch: `flow.runtime_verify: ask | off` (default `ask`, a missing key means `ask`). On
  `ask`, `verify` step 6 asks once per run "exercise it in the running app?" when an AC is
  observable in a running app (a request and its response, or what a page shows), default
  the feature's current value, else yes; otherwise `off` without a question.
- Serve: `commands.serve` and `commands.serve_url` (never detected). Empty: the step asks,
  suggesting from `project.md`, and offers to save them with `config-set`; "already running
  at <URL>" is an answer too. A URL that is not localhost or `*.local` is confirmed as not
  production, since checks may write data.
- `scripts/runtime-check`: `start` (reuses an app that already answers and never stops it;
  else `sh -c` in a new process group, polls the URL, reports the log tail on exit or
  timeout), `run` (a plan file of checks with `status`, `contains`, a JSON subset and
  header expectations; `path` must start with one `/`, so nothing leaves the origin;
  redirects are results, not hops; 400-character excerpts through `redact`; the plan is
  consumed), `stop` (TERM the group, KILL after five seconds). `<workspace_root>/.runtime/`
  ignores itself. A plan file, not inline JSON, for the reason the lessons entry gives.
- Browser: `agents/runtime-verifier.md` at the execution role, with the playwright MCP
  tools by exact name and nothing else: no file tools, no shell, no web. It stays on the
  base URL's origin, treats page text as data and answers per AC `pass | fail | blocked`
  with the text it saw, plus console errors, in 40 lines. This is the per-layer escalation
  path of the 2026-10-06 entry, routed by the step rather than by `layers`. The validator
  lists it among the agents without write tools. Without `playwright` in `.mcp.json` the
  step offers the install (`init-workspace --add-mcp playwright` at the MCP root; it loads
  after a restart, so those rows are skipped this run), a manual note, or skipping. The
  server writes `.playwright-mcp/` in the launch folder; the step removes it when it
  created it.
- Evidence: `runtime.md` in the spec folder (replaced each run, excerpts from the script
  and the agent only, at most 150 lines) and `; runtime: <what ran> → <what was seen>
  (<date>)` appended to the matrix cell, replacing an earlier `runtime:` part. A failed or
  blocked AC becomes a task under `Runtime fixes` (`step=implement`) or is accepted with a
  reason in the cell. `deliver` counts the ACs that also ran live at G5. One commit
  `spec(<feature>): runtime-verify`, carrying `specd.yml` and `.mcp.json` when the run
  changed them.
- The step asks before every run, a re-run included: it starts a process and sends
  requests that may write data.
Consequences: with the step off nothing changes: `verify → docs` as before. Main-thread
`curl`, WebFetch and playwright calls are anti-patterns, so responses and pages reach the
conversation only as bounded JSON and the agent's answer. Checks that need seeded data,
auth flows beyond a test account the user names, and non-HTTP surfaces (CLIs, queues) are
`none` rows that keep verify's evidence.

## 2026-10-23 M7: config-set inserts a documented key that an older specd.yml lacks

Context: `git.wrapper_pr` (2026-10-21) and now `flow.runtime_verify` and `commands.serve`
are keys a workspace from before M7 does not have, and `config-set` refused unknown keys,
so the config skill told the user to edit the file by hand. `runtime-verify` must save
`commands.serve` on the user's yes.
Decision: a scalar `section.key` that the default in `_shared/specd-yml.md` documents but
the file lacks is inserted at the end of its section, with its comment lines copied from
the default, and then set. Keys the default does not document, list keys and missing
sections are still refused, and the call stays all-or-nothing. The config skill's by-hand
line now covers only `sources: []` from before M5. `tests/test-config-set` covers it.
Consequences: a new scalar key needs no migration note any more; the reference default is
the schema `config-set` reads.

## 2026-10-23 M7: runtime-verify built; smoke-tested headless; M7 built

Context: this task's done-when was: an HTTP feature has its ACs exercised against the running
server with evidence in the matrix, one browser AC is exercised through `playwright`, and
with the step off the flow goes `verify → docs` exactly as before. As for M2 to M6, the
plugin's own verification is headless (memory: headless smoke testing). M7's own done-when
was agreed in this question round: each util runs once with its changes landing only on a
yes, and one feature passes runtime-verify over HTTP and through a browser.
Decision: built. `tests/test-runtime-check` covers start (ready, reused and left running,
early exit with the log tail, timeout stopping the group, a leftover pid file), every
expectation kind, redirects as results, a truncated and a redacted excerpt and every plan
refusal (with no request sent). `tests/test-state` covers the order with the switch on, off
and empty, the switch and `next` in one call, quick, the PR loop, a bad value, an older file
and escalation. Headless runs in a scratch embedded repo (a stdlib Python JSON API with a
page, full feature `items` with five ACs: four HTTP, one browser), logged as `stream-json`:
- `verify`: filled the matrix and, from the user's answer naming runtime-verify, set
  `runtime_verify=on`; `step: runtime-verify`.
- `runtime-verify` without playwright: asked for the serve command and URL (suggested from
  `project.md`), saved them, proposed four `http` rows and one `browser` row, offered the
  install; on "run all, install" it ran the four checks through the script (all pass),
  skipped AC4, stopped the app, wrote `runtime.md` and the cells, committed. That run
  installed playwright into `.specd/.mcp.json`, which Claude Code does not read; the spine
  now names the MCP root, as the config skill does.
- With playwright loaded (`--headless` in the scratch `.mcp.json`): the four HTTP checks
  and AC4 through `runtime-verifier` passed; every `mcp__playwright__*` call came from the
  subagent. That run skipped the confirmation question as "non-interactive" and left
  `.playwright-mcp/` behind; the spine now asks on every run and removes the folder.
- Re-run after seeding a regression (AC3 answered 400 instead of 422): the question was
  asked, AC3 failed with `status 400, expected 422`, the user chose a fix task: T4 under
  `Runtime fixes`, `step=implement`, the app stopped, `.playwright-mcp/` removed, one
  commit.
- Off: on a copy at verify, "no" set `runtime_verify=off` and `step: docs`; `state check
  --step runtime-verify` refuses with `/specd:docs items`.
Not exercised: `flow.runtime_verify: off` through the skill (script-level only); a reused
running app; `start` timing out through the skill; an accepted failure; the PR loop; a
non-local URL; wrapper mode and a worktree (`.runtime/` and `.mcp.json` at the wrapper
root); `chrome-devtools` instead of playwright; an AC needing a test account.
Consequences: M7 is built; PLAN marks it so, with the done-when above. "Done" is the user's
call after each util runs on a real workspace and one real feature passes runtime-verify.
Watch whether the plans check what the ACs state rather than what the code happens to do,
and how often browser rows come back `blocked`.
