# Spec-Driven Workflow — Plan

Name: **specd** (read "spec'd": spec-driven). Command prefix `/specd:`, config `specd.yml`, embedded folder `.specd/`.

Status: v4, updated 2026-10-09. v2 reworked modes, folders, flow and init; v3 split init into commands and restructured `docs/`; v4 settles the remaining open questions (section 6). Progress: M0 and M1 done, M2 built and run on real features (DECISIONS 2026-10-05/06 record the amendments), M3 built and awaiting its week of mixed tasks, M4 built (section 5). Git model amended by DECISIONS 2026-09-24: branch at `start`, commits per step. Light flows amended by DECISIONS 2026-10-06 M3: the step order per tier lives in `scripts/state`, specify-lite writes `spec.md` and `tasks.md`, trivial has G4 and G5. Wrapper mode amended by DECISIONS 2026-10-09 M4: the wrapper branch is merged by `close`, worktrees are opt-in and hold the wrapper and the code, the gate hook stays out.

## 1. Goal and non-goals

specd automates development with AI coding assistants while keeping code quality, maintainability and simplicity under human control. It is stack-agnostic, works on greenfield and brownfield projects, and can live inside the code repo or wrap around it from the outside.

It differs from the projects that inspired it (genkovich/sdd, AIDevTeamForge, spec-kit) in three deliberate ways. First, the source of truth may live outside the repo (Jira, Confluence, docs, chats), so specs start from an intake step rather than from a blank file. Second, feature artifacts are ephemeral: durable knowledge is distilled into `docs/` and the spec folder is cleaned, so the project never becomes a graveyard of spec files. Third, the location of workflow files is an abstraction (the *workspace*), so embedded and wrapper modes are the same code path.

Non-goals: a big fixed agent roster, a mandatory heavyweight document pipeline per feature, a custom CLI runtime, or support for every AI tool from day one.

## 2. Decisions

| Topic | Decision |
|---|---|
| Target tools | Claude Code first; logic kept in portable `SKILL.md` skills so Codex/Cursor adapters can follow |
| Distribution | Claude Code plugin served from this repo as its own marketplace; only the generated project layer lands in a workspace |
| Modes (v2) | Two: **wrapper** and **embedded**. AI attribution removed from commits in both |
| External sources | Pluggable adapters; v1 = local files and paste/URL per task; MCP adapters added per project; pure in-repo flow stays possible |
| Gates | After spec, after design, after tasks, during implementation (granularity setting), before deliver |
| Spec lifecycle (v2) | On close: distill to `docs/` + clean, full clean, or keep. No archive folder |
| Git authority | Up to a draft PR, after the final gate; configurable downwards |
| Verification | Project checks + acceptance-criteria coverage; TDD if chosen at init (test plan folded into tasks); runtime verification is an optional step |
| Flow tiers | Auto-triage proposes trivial/quick/full; you confirm or override; escalation mid-flow |
| Third-party skills | Vetted-source allowlist + two-stage security audit + your approval; otherwise generate |
| Review | Base reviewer in fresh context + optional specialist passes; critic agent at two fixed points only |
| State | Files are the state (`state.yml` per feature); capped `lessons.md` pruned by a util |
| Constraints | Token cost matters; parallel features are common |
| MVP | Init + full flow in embedded mode |
| Artifact language (v4) | English |
| Git conventions (v4) | Conventional Commits; ticket key in branch names when detected from git history or given at init |
| PR host (v4) | Asked at init; changeable later (`specd.yml` or `/specd:config`) when the remote changes |
| G4 granularity (v4) | Asked at init; default `phase`; changeable mid-flow via config or command |
| Secrets guardrail (v4) | Included: hook denies reads/edits of `.env`, key and credential files; redaction when snapshotting external docs |
| Embedded folder (v4) | `.specd/` |
| Wrapper docs (v4) | At init you choose whether `docs/` lands in the wrapper or in the project repo; a branch per feature in both repos |

## 3. Architecture

### 3.1 Modes and folder structure (v2)

Every skill resolves paths from `specd.yml`: `workspace_root` (specd files), `code_root` (the code), `docs_root` (defaults to `<workspace_root>/docs`). No skill hardcodes a path.

**Wrapper mode.** The wrapper is its own git repo; the code repo sits inside it, gitignored. Launch the assistant in the wrapper.

```
my-project-ai/               # wrapper git repo
  specd.yml
  CLAUDE.md                  # short; points to docs/
  .claude/  .mcp.json        # generated project skills/agents, MCP config
  docs/                      # persistent knowledge (see below)
  spec/
    auth/                    # one folder per feature: slug or ticket key
    TICKET-123/
  <project-name>/            # the code repo (gitignored); name from init
  .worktrees/<feature>/      # gitignored; opt-in (`git.worktrees`): a worktree of the wrapper
                             # on the feature branch, holding a worktree of the code repo on
                             # the same branch at <project-name>/ inside it
```

Agents commit to two repos: code changes to the code repo (`git -C <code_root>`), spec and docs changes to the wrapper repo, with the same branch name per feature in both, so a feature's code and its spec history line up. The PR is the code repo's; `close` merges the wrapper branch into the wrapper's default branch and removes the worktree (DECISIONS 2026-10-09 M4). A feature worktree is a complete wrapper layout, so resolving paths from inside it needs no special case, and the assistant runs either in the wrapper root or in a worktree, one session per parallel feature. At init you choose where `docs/` lands: in the wrapper (default, invisible to the client) or in the project repo (`docs_root` points there, the docs ship with the code). Both repos commit without AI attribution: the generated settings turn off Claude Code's co-author line, and the `deliver` skill forbids AI mentions in commit messages and PR bodies. Commit messages follow Conventional Commits; branch names carry the ticket key when the project uses one.

**Embedded mode.** Same layout minus the code folder: `specd.yml`, `docs/` and `spec/` live under `<repo>/.specd/`. If the team wants agent-maintained docs to be the real project docs, `docs_root` can point at the repo's existing `docs/`. Keeping the folder out of git for a team that shouldn't see it is a `.git/info/exclude` flag at init, not a separate mode.

**`docs/` — persistent knowledge, curated, size-conscious (v3).** Rule: anything loaded in full every session is a single small file; anything read selectively is a folder with an index, loaded by pointer.

```
docs/
  project.md          always loaded: what it is, how to run/test/lint, layout (≤100 lines)
  conventions.md      always loaded: code style, patterns, naming, testing rules
  lessons.md          always loaded: corrections you gave the agents; capped, pruned
  architecture/       overview.md + one file per subsystem or area
  decisions/          0001-title.md … (context, decision, consequences) + README index
  data-models/        one file per domain, only if the project has them
  features/           README index + one file per shipped feature: what it does, its flows, where it lives; written by `docs`
```

`lessons.md` stays a single capped file on purpose: it is a holding area, and growth is the signal to promote items into `conventions.md` or a decision, or prune them. In brownfield, existing project docs are linked from `architecture/overview.md`, not duplicated.

**`spec/<feature>/` — the working set, ephemeral.**

```
brief.md      what was asked: input condensed, with provenance (from intake)
spec.md       what we agreed to build: problem, scope, acceptance criteria, open questions
design.md     optional; only the sections the feature needs (see 3.3)
tasks.md      ordered tasks with done-when criteria and test plan
review.md     reviewer findings
state.yml     tier, current step, gate approvals, task checklist
```

**Closing a feature** (`close`, policy chosen per project, overridable per feature):

- `distill` (default for full): the durable knowledge was already extracted into `docs/` by the `docs` step before the PR (`features/<name>.md`, new decision files, architecture/data-model deltas); `close` deletes the spec folder once the PR is settled (DECISIONS 2026-10-06).
- `clean` (default for trivial/quick): delete the spec folder; nothing worth keeping.
- `keep`: leave it, mark closed in `state.yml`; `status` lists kept folders older than N days so they don't pile up, and `spec-clean` distills or deletes them in batch.

Git history is the archive in all cases.

### 3.2 Three layers of knowledge

| Layer | Lives in | Lifetime |
|---|---|---|
| Principles | the plugin | permanent, same everywhere: coding principles (think before coding, simplicity first, surgical changes, goal-driven execution; clean code/architecture, DRY, YAGNI, KISS), flow definitions, core agents |
| Project knowledge | `docs/` + generated project skills/agents | long-lived, curated |
| Working set | `spec/<feature>/` | one feature |

Agents load principles by skill trigger, project knowledge just-in-time by pointer, and the working set only for the active feature.

### 3.3 Feature flow (v2)

```
start ──▶ specify ─G1▶ [design] ─G2▶ tasks ─G3▶ implement ⇄ checks ─G4▶ review ▶ verify
      (intake+triage)  ▲critic          ▲critic
      ▶ [runtime-verify] ▶ docs ─G5▶ deliver ▶ [feedback ▶ implement ▶ verify ▶ deliver]* ▶ close ▶ merge
```

Square brackets = optional. Every step ends with a handoff block (what was produced, what to review, next command); `/clear` between steps is the norm; a step refuses to run if the previous gate is not approved in `state.yml`.

**How a feature starts: intake → triage → specify.** These are three concerns in a fixed order, and the first two are cheap enough to be one command.

- *Intake* collects raw input — a ticket key, URL, file, pasted text, or just your sentence — and distills it into `brief.md`. The brief is *what was asked*: the ticket, the pages it links to, the thread you pasted and your own sentence, condensed to a page with a link back to each source and a list of what the input does not say. The spec, by contrast, is *what we agreed to build*. Keeping them apart gives traceability (a spec that deviates from the ticket is visibly deliberate), lets triage size the work before a spec exists, and keeps external content isolated: the brief is written by an agent that treats fetched text as data, so an injection in a wiki page never reaches the main flow. For a one-sentence request the brief is that sentence plus the gaps, three lines.
- *Triage* reads the brief and glances at the codebase (`explorer`, cheap model) to estimate size and risk from signals: modules touched, new dependencies, schema/API changes, cross-cutting concerns, ambiguity. It proposes a tier and writes it to `state.yml`; you confirm or override. You can't size what you haven't read, so it comes after intake; and the tier decides how deep the spec goes, so it comes before specify.
- *Specify* turns the brief into `spec.md` through an interview: problem, scope, out of scope, acceptance criteria, open questions.

So the command surface is `/specd:start <feature> [--from TICKET-123 | url | file]` (creates `spec/<feature>/`, runs intake and triage, asks you to confirm the tier) followed by `/specd:specify`. Triage is re-checked after specify and during implementation; if a quick task trips a signal, the flow stops and proposes escalation, carrying over what exists.

**Steps.**

| Step | Runs as | Tier | Output / gate |
|---|---|---|---|
| start | skill + source adapters + `explorer` | cheap | `brief.md`, tier in `state.yml` (you confirm) |
| specify | skill, interactive | judgment | `spec.md`; critic pass; **G1** |
| design | `architect` drafts, main thread interviews | judgment | `design.md`; critic pass; **G2** |
| tasks | skill | judgment | `tasks.md`; **G3** (confirm or edit the list) |
| implement | `implementer` per task | execution | code + tests; project checks with bounded self-repair; **G4** at `task` / `phase` (default) / `end`; risky tasks always stop; `WIP:` commit per task until the PR exists (after G4 at `task`); optional task selection |
| review | `reviewer`, fresh context: spec, design, tasks, diff only | judgment | `review.md`; specialist passes if enabled; findings loop back to implement |
| verify | skill | execution | AC → evidence matrix filled (test, check, or manual note) |
| runtime-verify | optional skill | execution | exercises the feature via browser MCP / HTTP |
| docs | skill | judgment | `docs/features/<name>.md`, decision files, architecture/data-model deltas, written before the PR so it carries them; skipped by policy for trivial/quick |
| deliver | skill | cheap | **G5** full diff + review → optional squash of the `WIP:` commits before the first push, push, draft PR |
| feedback | skill | cheap | PR comments (via `pr-comments`) → fix / reply / skip; fixes become tasks, `step` back to implement; replies printed, never posted |
| close | skill | cheap | retention policy only (distill: folder removed once docs wrote the record; clean; keep), on the branch before the merge |

**Design, kept optional and in one file.** Instead of separate `design`, `data-model`, `sequences`, `api` commands, one `design` step opens by deciding which sections the feature needs, from spec signals and tier, and tells you before writing anything:

| Section | Included when |
|---|---|
| Approach + decisions | always, when design runs at all |
| Data model | entities, schema, or persisted state shape change |
| API / contracts | new or changed endpoints, events, or module interfaces |
| Sequences | more than one actor/service or async flow; drawn as Mermaid |
| UX flows / screens | UI feature with more than one screen or state machine |

Full tier runs design by default (sections auto-selected, you can add/remove); quick tier skips it unless a signal fires; trivial never runs it. Decisions made here become files in `docs/decisions/` at close.

**Tasks and the test plan.** `tasks` reads spec and design and writes `tasks.md`: phases → tasks, each with goal, files, `done-when` (verifiable), depends-on, and a risk flag. With TDD on, each task also carries a `tests` block (test cases derived from the acceptance criteria it covers), and the file ends with a coverage matrix *acceptance criterion → task → test*. That is sdd's `plan-tests` without a separate command: the matrix is produced where the tasks are, `implement` writes the listed tests first, and `verify` fills the evidence column. With TDD off the matrix still exists; evidence may be a check or a manual note.

**Critic without spam.** A `critic` agent (devil's advocate: ambiguities, contradictions, missing failure modes, hidden assumptions) runs at exactly two points by default — end of `specify` and end of `design`, before their gates — because those are the places where a missed ambiguity is most expensive and the artifact is short. It gets only the artifact and `docs/project.md`, runs in fresh context, and returns at most ten ranked findings, which the step folds into the open-questions list for you to resolve at the gate. Full tier only. Config `critic: gates | off | always`, plus `/specd:critique <file>` on demand.

**Tiers.**

- *Trivial*: start → implement (principles + checks) → G5 deliver → close (`clean`). No spec file; the request is recorded in `state.yml`.
- *Quick*: start → specify-lite (spec and tasks in one short file, one gate) → implement → review → G5 → close (`clean` or `distill`). `fix` is quick with a reproduce-first step.
- *Full*: everything above.

### 3.4 Core agents and skills (stack-agnostic)

Agents exist only where an isolated context pays for itself: heavy reading, or independence from the implementer's reasoning. Interactive steps stay in the main thread.

Agents: `explorer` (codebase scan, cheap, returns a map with file:line pointers), `researcher`, `architect`, `critic`, `implementer`, `reviewer`, specialist reviewers (`security`, `performance`, `accessibility`, `tests`), `doc-writer`, `skill-auditor`.

Stack specialisation is knowledge, not agents: a task names a `layer` (`frontend`, `backend`, …), `specd.yml` `layers` maps each layer to project skill files, and `implement` and `review` pass those files to the one `implementer` / `reviewer` as "read first". Subagents cannot spawn subagents, so routing always happens in the main thread; a per-layer agent is added only when a layer needs tools the generic agent lacks (a browser or database MCP).

Skills: `init`, `onboard`, `scaffold`, `toolsmith`, `config` (change a setting mid-flow, e.g. gate granularity or PR host), `start`, `specify`, `design`, `tasks`, `implement`, `review`, `verify`, `runtime-verify`, `docs`, `deliver`, `feedback`, `close`, `fix`, `critique`, `status` (resume), `principles`, `skill-audit`, utils (`research`, `analyze`, `docs-clean`, `spec-clean`, `lessons-prune`).

Model tiers are roles, not model names: `judgment`, `execution`, `cheap`, mapped in `specd.yml` (default opus/sonnet/haiku), overridable per role.

### 3.5 Initialization (v3)

A single init command would drown in context on any real repo, so initialization is four commands with state on disk, and none of them scans in its own context: every scan is an `explorer` run that returns a bounded summary, and the main thread only holds summaries and your answers.

| Command | What it does | Context cost |
|---|---|---|
| `/specd:init` | Mechanical setup: mode, folders, greenfield/brownfield detection, command detection (cascade: config override → Makefile → package.json scripts → language manifests), `specd.yml`, CLAUDE.md pointer block, `.mcp.json` with Context7, no-attribution settings, secrets guardrail hook. Interview limited to mode, retention, TDD, gate granularity (default `phase`), PR host, ticket-key convention if not detected from git history, and in wrapper mode where `docs/` lands | minutes, cheap |
| `/specd:onboard [section]` | The knowledge work, one `docs/` section at a time: project → architecture → conventions → data models → decisions. Each section is one scan pass (brownfield) or one interview (greenfield) plus gap questions, written to disk before the next section starts. No argument = all sections for the whole project; resumable after `/clear` from the first unfinished section; `onboard architecture` refreshes one section later | one section per context |
| `/specd:scaffold` | Greenfield only: builds the skeleton from `docs/architecture/` — structure, tooling (package manager, lint, format, typecheck, tests), one smoke test, `.gitignore` — and verifies build/test/lint pass. Runs as a normal quick-tier feature (`spec/scaffold/`) so it gets a gate and a review | one feature |
| `/specd:toolsmith` | Project skills and MCP recommendations (3.6). Called last by init's handoff; re-runnable alone when the stack changes | delegated to agents |

Both project kinds share one mechanism: a **knowledge checklist** — the questions each `docs/` section must be able to answer (purpose and users, stack and versions, layout, commands, boundaries and key flows, data model, integrations, conventions, testing approach, git/PR rules, sources of truth). `onboard` fills the checklist from whatever exists and interviews only for the gaps.

**Greenfield** (`init` finds no meaningful code): `onboard` runs as interviews. Project section = idea interview (goals, users, constraints, preferences, deadlines, must/should/won't); architecture section = stack, structure, key decisions and reasons, integrations, testing strategy, with `researcher` + Context7 available for "what is the current recommended way to X". If the material already exists somewhere, you point at the source or paste it; `intake` distills it and the interview covers only gaps. Then `scaffold`, then `toolsmith`.

**Brownfield** (`init` finds code): `onboard` runs as scans. Existing docs and any CLAUDE.md/AGENTS.md are read, never overwritten; external sources (architecture pages, wikis, ADRs) can be pointed at or pasted and are snapshotted with a provenance header. The gap interview covers what code and docs can't tell: domain, team conventions, sources of truth, git/PR rules. Then `toolsmith`.

Each section ends with a summary you sign off.

### 3.6 Project-specific skills: toolsmith and skill-audit

`toolsmith` is a command on the outside and agents on the inside: it takes the detected stack and, per need (e.g. "React testing conventions", "NestJS module layout"): has `researcher` search the allowlisted sources in `specd.yml` (official Anthropic skills, vendor-official repos, anything you add); fetches candidates into a quarantine folder that Claude Code does not load; runs `skill-audit`; shows you the report; installs only on approval, pinned to a commit hash in `skills.lock`. If nothing suitable passes, it generates a project skill from codebase conventions plus Context7 docs. Each installed or generated skill is registered under the layer it serves in `specd.yml` `layers`, which is how it reaches the implementer (3.4).

`skill-audit` is two-stage because an LLM auditor reading hostile text is itself an injection target. Stage one is a deterministic script: hidden/bidi Unicode, encoded blobs, URLs and network calls, `curl | sh` patterns, bundled scripts and hooks, over-broad `allowed-tools`, references to secrets or env files. Stage two is the `skill-auditor` agent with read-only tools and no network, treating content strictly as data and flagging instructions that override behaviour, exfiltrate, or exceed the skill's stated purpose. Nothing is executed during audit; it re-runs on updates.

The same data-not-instructions rule applies to `intake`: fetched content is summarized by an agent that cannot act on it.

### 3.7 Sources

`specd.yml` lists sources with a type: `local` (paths/globs), `paste`, `url`, `mcp:<server>` (Atlassian, Google Drive, Slack, GitHub…). `start` accepts a ticket key, URL, file or pasted text per feature and falls back to asking. It always writes a distilled brief with links back, never raw dumps. A util refreshes snapshotted docs.

### 3.8 MCP

Context7 always. Everything else is proposed at init from the stack and sources — browser/DevTools MCP for frontend, database MCP for backend, tracker/wiki MCPs for sources — installed only on confirmation. In wrapper mode `.mcp.json` lives in the wrapper.

### 3.9 Context-engineering rules for specd itself

Go into `docs/AUTHORING.md`; a validator script enforces the mechanical ones.

- `SKILL.md` is a short spine (≤150 lines); detail sits in `references/` and `templates/`, loaded on demand. Descriptions are written as triggers.
- Shared blocks (handoff format, gate protocol, principles) live once in `skills/_shared/` and are referenced, never copied.
- Each step declares inputs and outputs and reads only those files. State passes through disk, not conversation.
- Subagents return a bounded summary with file:line pointers, never file dumps.
- Deterministic work (command detection, static audit, state validation) is a script, not a prompt.
- The generated CLAUDE.md stays under ~60 lines and only points to `docs/`.
- Hooks are few: a secrets guardrail that denies reading or editing `.env`, key and credential files; `intake` redacts secret-looking strings when snapshotting external docs. Gate enforcement is `state check` in every skill, not a hook (DECISIONS 2026-10-09 M4).

## 4. Repo layout (this folder)

```
ai-workflow/
  .claude-plugin/        plugin.json, marketplace.json
  skills/<name>/         SKILL.md, references/, templates/
  skills/_shared/
  agents/
  hooks/
  scripts/               validate, detect-commands, audit-static
  docs/                  PLAN.md, DECISIONS.md, AUTHORING.md
```

## 5. Milestones

Each milestone ends in something you use on a real task; findings go to `DECISIONS.md` before the next starts.

| # | Milestone | Scope | Done when | Status |
|---|---|---|---|---|
| M0 | Foundations | Repo scaffold, plugin manifest, `principles` skill, `specd.yml` schema, path resolution, no-attribution settings, `AUTHORING.md`, validator | Plugin installs locally; principles skill triggers on a coding request | done 2026-09-22 |
| M1 | Init + onboard (embedded) | `init` (detection, `specd.yml`, CLAUDE.md, Context7), `onboard` with knowledge checklist, per-section state and resume, brownfield scans + gap interview, greenfield interviews + `scaffold` | Onboard on one real brownfield repo gives docs you'd sign off without context overflow; greenfield init + onboard + scaffold yields a project that builds and tests | done 2026-09-24; `config` skill added (see DECISIONS) |
| M2 | Full flow | start (intake local/paste + triage), specify, design, tasks (+ test plan), implement, review (base), verify, deliver, close (`distill`/`clean`/`keep`), `status` | One real feature shipped as a draft PR; resume after `/clear` works. **MVP** | built 2026-09-24; awaiting the real-feature run (see DECISIONS) |
| M3 | Light flows + critic | trivial, quick, `fix`, escalation, `critic` at gates, `critique` on demand | A week of mixed tasks without wanting to bypass the flow | built 2026-10-06; the week of mixed tasks is the user's (see DECISIONS) |
| M4 | Wrapper + parallel | Wrapper init, two-repo commits, worktrees per feature | Two features in parallel on a client-style repo with zero files added to it | built 2026-10-09; headless smoke run of two parallel features on a scratch client repo (see DECISIONS) |
| M5 | Sources | `url` adapter, first MCP adapter, snapshot + refresh | A ticket becomes an approved spec without copy-paste | |
| M6 | Toolsmith + audit | `toolsmith` command, allowlist search, quarantine, two-stage audit, `skills.lock`, generation fallback, specialist reviewers, MCP recommendations | Audit catches a seeded malicious test skill; one community skill installed via the pipeline | |
| M7 | Utils | research, analyze, docs-clean, spec-clean, lessons-prune, runtime-verify | — | |
| M8 | Portability + team | `install.sh` for Codex/Cursor, team-sharing guide, evals for key skills | Full flow runs on a second assistant | |

After M2 specd is developed with specd.

## 6. Settled questions (v4)

All previously open questions are now decisions (see the v4 rows in section 2): English artifacts; Conventional Commits with ticket keys in branch names when the project uses them; PR host and gate granularity asked at init and changeable mid-flow with `/specd:config`; secrets guardrail hook included; `.specd/` in embedded mode; in wrapper mode `docs/` location chosen at init and one branch per feature in both repos.

## 7. Next step

M3's week of mixed tasks (trivial, quick, fixes, one escalation) on a real repo continues on the user's side; findings go to `DECISIONS.md` first, the triage table (`skills/start/references/triage.md`) and the escalation signals being the parts most likely to need tuning. M4 is built: the first real wrapper around a client repo, with `git.worktrees` on for two features at once, is the run that closes it (dependency install per worktree and the `close` merge are the parts to watch). Then M5: the `url` adapter, the first MCP adapter, snapshot and refresh, with the isolating intake agent the 2026-09-24 sources entry deferred.
