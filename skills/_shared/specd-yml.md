# specd.yml

**Reference-only.** Not a skill. The single source of truth for the workspace config file.
Written by `init` (create) and `config` (change); read by every other skill. Skills that read it
never write it.

## Where it lives

Embedded mode: `<repo>/.specd/specd.yml`. Wrapper mode: `<wrapper>/specd.yml`. The folder holding
it is `workspace_root`; see [`paths.md`](./paths.md).

## Default file

`init` writes this file verbatim, then changes the keys it asked about. Comments are part of the
file and stay in place.

```yaml
specd: 1                     # schema version; bump only on incompatible key changes
mode: embedded               # embedded | wrapper
project: ""                  # display name; in wrapper mode also the code folder name

paths:                       # relative to workspace_root (the folder holding this file)
  code_root: ".."            # embedded: the repo root; wrapper: "./<project>", written by init
  docs_root: "docs"          # persistent knowledge; wrapper: "<project>/docs" to ship with the code
  spec_root: "spec"          # ephemeral working set, one folder per feature

git:
  authority: draft_pr        # draft_pr | push | commit | none: the most deliver may do
  pr_host: github            # github | gitlab | none
  ticket_key: ""             # prefix such as "PROJ-"; empty = no ticket convention
  worktrees: false           # wrapper only: start opens each feature in .worktrees/<feature>/
                             # (wrapper + code worktrees on the feature branch) for parallel work

flow:
  gate_granularity: phase    # task | phase | end: where implement stops for G4
  tdd: false                 # tests first; the coverage matrix exists either way
  critic: gates              # gates | off | always
  specialists: ask           # ask | off: review proposes specialist passes from the diff
  retention: distill         # distill | clean | keep: docs + close policy for full tier
  keep_days: 30              # status warns about kept spec folders older than this

models:                      # role -> model; the only place a model name may appear
  judgment: opus
  execution: sonnet
  cheap: haiku

commands:                    # empty = detected (config -> Makefile -> package.json -> manifests)
  test: ""
  lint: ""
  format: ""
  typecheck: ""
  build: ""

docs:
  lessons_max_lines: 80      # cap for lessons.md; lessons-prune enforces it

sources:
  mcp: none                  # none | atlassian: the MCP server that fetches bare ticket keys
                             # (PROJ-123) and its own page URLs; URLs, files and pastes need no key

skills:                      # GitHub repos toolsmith may fetch third-party skills from;
  allowlist:                 # change with /specd:config --add / --remove
    - anthropics/skills
  discovery: skills.sh       # skills.sh | off: find candidates in the skills.sh index (the
                             # search find-skills uses) and offer their repos for the allowlist

layers:                      # layer -> files implement and review add to "Read first" for
                             #     tasks of that layer; paths relative to code_root. Filled by
                             #     toolsmith or /specd:config --add, e.g.
                             #     frontend:
                             #       - .claude/skills/react-conventions/SKILL.md
```

## Key semantics

| Key | Values | Used by |
|---|---|---|
| `specd` | integer | every reader, to refuse an unknown schema |
| `mode` | `embedded`, `wrapper` | path resolution (skills name roots, never the mode) |
| `project` | string | wrapper code folder name, generated docs |
| `paths.*` | relative or absolute path | path resolution |
| `git.authority` | `draft_pr` > `push` > `commit` > `none` | deliver stops at this level |
| `git.pr_host` | `github`, `gitlab`, `none` | deliver picks the PR command |
| `git.ticket_key` | prefix string | start (branch names), deliver |
| `git.worktrees` | bool | start (`scripts/worktree add`), close (remove); wrapper mode only, embedded ignores it |
| `flow.gate_granularity` | `task`, `phase`, `end` | implement; risky tasks always stop |
| `flow.tdd` | bool | tasks (tests block), implement (tests first) |
| `flow.critic` | `gates` (before G1 and G2 on the full tier), `always` (quick's G1 too), `off` | specify, design; `critique` runs regardless |
| `flow.specialists` | `ask` (review proposes security, performance, accessibility or tests passes from the diff and asks), `off` | review |
| `flow.retention` | `distill`, `clean`, `keep` | docs (write the record on `distill`) and close; trivial and quick default to `clean` |
| `flow.keep_days` | integer | status, spec-clean |
| `models.<role>` | model name | any skill that spawns an agent; roles only elsewhere |
| `commands.*` | shell command | implement, verify, scaffold; empty = detect |
| `docs.lessons_max_lines` | integer | lessons-prune |
| `sources.mcp` | `none`, `atlassian` | start, fix, onboard, refresh: a bare ticket key (and an `*.atlassian.net` URL) goes through this server ([`sources.md`](./sources.md)); `none` asks for a paste. A file from before M5 has `sources: []`: replace that line by hand with the two lines above |
| `skills.allowlist` | list of GitHub `owner/repo` | toolsmith: the only repos it fetches from (`skill-fetch` refuses others); `config-set --add` / `--remove` |
| `skills.discovery` | `skills.sh`, `off` | toolsmith: `skills.sh` sends each need's search words (never code) to the skills.sh index and offers the repos it finds for the allowlist; `off` searches the allowlist only. A file from before this key: missing means `skills.sh` |
| `layers.<name>` | list of paths, relative to `code_root` (not `workspace_root`) | tasks (the `layer` vocabulary), implement and review (files the agent reads first); written by toolsmith or `config-set --add layers.<name>=<path>` |

Retention per tier: trivial and quick close with `clean` unless the feature's `state.yml` says
otherwise; full uses `flow.retention`.

Next to this file, `toolsmith` keeps `skills.lock` (one section per installed or generated
skill: source, repo, path, commit, sha256, dir, layer, verdict, audited; written only by
`scripts/skill-lock`) and the gitignored `.quarantine/` folder that candidates are fetched
into for the audit.

## Rules for readers

- A missing key means its default above.
- Unknown keys are ignored, never removed.
- A malformed file: warn once, use all defaults, do not rewrite.
- Never write. Suggest `/specd:config` when a value should change.

## Rules for writers (`init`, `config`)

- Patch key by key. Never regenerate the file; comments, order and unknown keys survive.
- Write values in the documented form: bare `phase`, not `"phase"`; `false`, not `"false"`.
- Show `old -> new` for each changed key, and mark values that were derived rather than asked.
- Do not repair a malformed file silently; show the problem and ask.
