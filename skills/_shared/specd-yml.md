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

sources: []                  # M5. Items: {type: local, paths: [...]} | {type: url}
                             #     | {type: paste} | {type: "mcp:<server>"}

skills:                      # M6. Where toolsmith may search for third-party skills
  allowlist:
    - anthropics/skills

layers:                      # M6. layer -> files implement adds to "Read first" for tasks of
                             #     that layer; paths relative to code_root. Filled by toolsmith
                             #     or by hand, e.g.
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
| `flow.retention` | `distill`, `clean`, `keep` | docs (write the record on `distill`) and close; trivial and quick default to `clean` |
| `flow.keep_days` | integer | status, spec-clean |
| `models.<role>` | model name | any skill that spawns an agent; roles only elsewhere |
| `commands.*` | shell command | implement, verify, scaffold; empty = detect |
| `docs.lessons_max_lines` | integer | lessons-prune |
| `sources` | list | start (M5) |
| `skills.allowlist` | list of `owner/repo` | toolsmith (M6) |
| `layers.<name>` | list of paths, relative to `code_root` (not `workspace_root`) | tasks (the `layer` vocabulary), implement and review (files the agent reads first); written by toolsmith (M6) or by hand |

Retention per tier: trivial and quick close with `clean` unless the feature's `state.yml` says
otherwise; full uses `flow.retention`.

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
