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
