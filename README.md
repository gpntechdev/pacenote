# specd

Spec-driven development workflow for AI coding assistants, packaged as a Claude Code plugin.
Read "spec'd". Stack-agnostic; lives inside a code repo (`.specd/`) or wraps around it.

Status: M6 (toolsmith, two-stage skill audit, specialist reviews, MCP proposals) is built;
M5 is done. See `docs/PLAN.md` for the plan of record and milestones.

## Install

From GitHub, inside Claude Code:

```
/plugin marketplace add gpntechdev/specd
/plugin install specd@specd
```

From a local checkout, for development:

```
claude --plugin-dir /path/to/specd
```

Then `/reload-plugins` after edits. Skills appear as `/specd:<name>`.

## Getting started

Set up once per repository, then run the flow per feature. Every command ends with a handoff
block naming the next one; `/clear` between commands is the norm, and `/specd:status` shows
where each feature stands and what to run next.

```
brew install gh && gh auth login          # once per machine (glab for GitLab)
cd <repo> && claude --plugin-dir /path/to/specd

/specd:init                               # mechanical setup, one short interview
/specd:init --wrapper <folder|url>        # or: your own repo around a client repo that
                                          # must get no files; launch the assistant here
/specd:onboard                            # one docs section per run: project, architecture,
                                          # conventions, data-models, decisions
/specd:scaffold                           # greenfield only
/specd:toolsmith                          # project skills per layer from the allowlist, audited
                                          # and pinned, or generated; MCP servers for the stack

/specd:start <feature> --from <file|url|PROJ-123>
                                          # or paste the ticket text; brief + triage, you confirm
                                          # the tier (or pass --tier), branch
/specd:specify <feature>                  # spec.md, critic pass, gate G1 (quick: tasks.md too, G1+G3)
/specd:design <feature>                   # design.md by the architect agent, critic pass, gate G2
/specd:tasks <feature>                    # tasks.md with the coverage matrix, gate G3
/specd:implement <feature> [T1-T3]        # implementer agent per task, WIP commit per task until the PR,
                                          # gate G4 at the configured granularity
/specd:review <feature>                   # reviewer agent in a fresh context, then optional
                                          # security / performance / accessibility / tests
                                          # passes; fixes become tasks and send you back to implement
/specd:verify <feature>                   # evidence for every acceptance criterion
/specd:docs <feature>                     # feature record, decisions, doc deltas, before the PR
/specd:deliver <feature>                  # checks, gate G5, optional squash; you choose push / PR
/specd:feedback <feature>                 # PR comments -> fix tasks (back to implement) or replies
/specd:close <feature>                    # retention: remove or keep the spec folder, then merge

/specd:fix <feature> "<symptom>"          # a bug: brief, reproduction first (failing test or a
                                          # command), then specify -> implement -> review -> deliver
/specd:critique <path>                    # the critic over any spec, design or document, on demand
/specd:refresh <feature>                  # re-fetch its sources, report what changed, name the gate
```

Three tiers, proposed by triage at `start` and confirmed by you: **trivial** (`start →
implement → deliver → close`, no spec), **quick** (`start → specify → implement → review →
deliver → close`, spec and tasks in one gate) and **full** (every step above). A light feature
that trips a signal mid-flow is offered an escalation; `/specd:start <feature> --tier <tier>`
escalates by hand and carries the work over.

`/specd:config key=value` changes a setting later (gate granularity, TDD, retention, PR
host, critic, specialist passes, model roles); `--add` / `--remove` edit the skills
allowlist and the `layers` lists. `sources.mcp=atlassian` installs the Atlassian MCP server so a
ticket key fetches the Jira issue and up to five linked pages; fetched pages are redacted
before they are saved and summarised by an agent that cannot act on them. `git.authority` in `specd.yml` caps what the flow may do with
git: `none`, `commit`, `push` or `draft_pr` (default).

Third-party skills are hostile until audited. `toolsmith` fetches candidates only from the
repos in `skills.allowlist`, at a pinned commit, into a gitignored `.quarantine/` that
Claude Code never loads. A static script (`audit-static`) and an isolated `skill-auditor`
agent both read it, nothing is executed, and a skill is installed only on your yes when
neither stage blocks it. `skills.lock` records the commit and a hash of the installed
files, and every skill is listed under its layer in `specd.yml` `layers`, which is how the
implementer and the reviewer get it.

In wrapper mode the spec folder and docs commit to the wrapper on a branch of the same
name as the code branch; the PR is the code repo's and `close` merges the wrapper branch.
`/specd:config git.worktrees=true` makes each `start` open the feature in
`.worktrees/<feature>/` (wrapper and code worktrees together), so features run in
parallel, one session per worktree or all from the wrapper root with the feature named.

## Layout

```
.claude-plugin/   plugin.json, marketplace.json
skills/<name>/    SKILL.md spine + references/ + templates/
skills/_shared/   blocks referenced by many skills: gates, handoff, state, paths, sources, critic
agents/           explorer, intake, researcher, architect, critic, implementer, reviewer,
                  specialist, skill-auditor
hooks/            secrets guardrail, source guard (snapshots and the skill quarantine)
scripts/          deterministic helpers: validate, resolve-paths, detect-repo,
                  detect-commands, config-set, init-workspace, state, worktree, run-checks, squash-wip,
                  pr-comments, redact, fetch-source, refresh-source, audit-static, skill-fetch,
                  skill-lock
tests/            test-audit and the audit fixtures (a seeded malicious skill, a clean one)
docs/             PLAN.md, DECISIONS.md, AUTHORING.md
```

## Contributing

Read `docs/AUTHORING.md` before adding or changing a skill. Run `scripts/validate`,
`tests/test-audit` and `claude plugin validate .` before committing. Decisions go to `docs/DECISIONS.md`.
