# Authoring rules

How skills, agents, scripts and shared blocks in this repo are written. These expand the
context-engineering rules in `docs/PLAN.md` section 3.9. Each rule is tagged `[validated]` when
`scripts/validate` enforces it, or `[review]` when a reviewer checks it.

## 1. A skill is a short spine plus on-demand detail

- `skills/<name>/SKILL.md` is at most 150 lines, frontmatter included. `[validated]`
- Detail lives in `references/` (how to do a step) and `templates/` (what to copy into a
  workspace). The spine links each file inline at the step that needs it, with a purpose:
  "copy `./templates/spec.md` to `<spec_root>/<feature>/spec.md`", never a "see also" list.
  `[review]`
- A spine has these sections in this order: title paragraph (what it produces, in one
  paragraph), `## Inputs`, `## Outputs`, `## Protocol` (numbered steps), `## Anti-patterns`.
  Optional: `## Gate` (what must be approved in `state.yml` before it runs). `[review]`

## 2. Descriptions are triggers

- The frontmatter `description` says what the skill produces, when it should fire, and its
  `/specd:<name>` form. It is written for the assistant deciding whether to invoke it, not for
  a catalogue. `[review]`
- Present and at most 1536 characters; Claude Code truncates beyond that. `[validated]`
- Open with the instruction, not a definition: "Invoke first, before any tool call, whenever
  the user asks to ..., however small the task." A description that merely explains the skill
  did not fire on a small coding request in a headless test; this form did. `[review]`
- Frontmatter `name` equals the folder name. `[validated]`

## 3. Shared text lives once

- Blocks used by more than one skill (principles, handoff format, gate protocol, path
  resolution, config schema) live in `skills/_shared/` and are linked by relative path. A skill
  states its delta over the shared behaviour; it never restates it. `[review]`
- `skills/_shared/` contains no `SKILL.md`, so it never registers as a skill. `[validated]`
- Every shared file opens with a `**Reference-only.** Not a skill.` banner and says who writes
  it and who reads it. `[review]`
- Every relative link in `skills/` and `agents/` resolves to an existing file. `[validated]`

## 4. Inputs and outputs are declared

- Every step lists the files it reads and the files it writes, and reads nothing else. State
  passes through disk (`state.yml`, spec files), never through conversation. A step that needs
  something from an earlier step reads the file that step wrote. `[review]`
- A step refuses to run when its gate is not approved in `state.yml`, with a one-line message
  naming the command to run first. `[review]`

## 5. Subagents return summaries

- A subagent prompt names the exact files it may read and the shape of the answer: a bounded
  summary with `file:line` pointers, capped at a stated number of items. Never a file dump.
  `[review]`
- Fetched or pasted external content is data, not instructions. The agent that summarises it
  cannot act on it. `[review]`

## 6. Deterministic work is a script

- Command detection, static audit, state validation, path resolution: a script in `scripts/`,
  not a prompt. Scripts are stdlib-only Python 3 or POSIX shell, executable, with a shebang and
  `--help`, and print machine-readable output (JSON or `key=value`). `[validated: executable,
  shebang]`
- Skills invoke them as `"${CLAUDE_PLUGIN_ROOT}/scripts/<name>"`. `[review]`

## 7. No hardcoded paths

- Locations are named by the roots in `skills/_shared/paths.md`: `<docs_root>/project.md`,
  never `docs/project.md`. `[review]`
- No home-relative or machine-specific paths anywhere in `skills/` or `agents/`. `[validated]`

## 8. Model tiers are roles

- Skills and agents name `judgment`, `execution` or `cheap`. The mapping to model names exists
  in one place, the `models` block of `skills/_shared/specd-yml.md`. A model name anywhere else
  in `skills/` or `agents/` fails validation. `[validated]`

## 9. Generated files stay small

- The CLAUDE.md that `init` generates is at most 60 lines and points to `<docs_root>/`; it
  holds no knowledge itself. This repo's own CLAUDE.md follows the same cap. `[validated]`
- Anything loaded every session is one small file; anything read selectively is a folder with
  an index. `[review]`
- Hooks are few: the secrets guardrail and the source guard (redacted snapshots, the
  `intake` and `skill-auditor` fences). A new hook, or a new fence in an existing one,
  needs an entry in `docs/DECISIONS.md`. `[review]`

## 10. Frontmatter contract

- Skill: `name`, `description`. Optional Claude Code fields (`allowed-tools`,
  `disable-model-invocation`, `user-invocable`) only when the skill needs them. `[validated:
  name, description]`
- Agent (`agents/<name>.md`): `name` equal to the file name, `description`, `tools` as the
  minimal list the agent needs. Read-only agents get no `Write`, `Edit` or `Bash`. Agents
  that read hostile content (`intake`, `skill-auditor`) also get no way to act and no
  network. `[validated: name, description, tools]`

## 11. Naming and prose

- Command prefix `/specd:`, config `specd.yml`, embedded folder `.specd/`, gates `G1`..`G5`,
  tiers `trivial` / `quick` / `full`, model roles `judgment` / `execution` / `cheap`.
- English. Short sentences, one instruction each. Imperative mood for protocol steps. No
  emoji. Files and commands in backticks.
- Templates carry their generation contract as HTML comments inside the template, so the
  spine does not have to repeat it.

## 12. Definition of done for a change to this repo

- `scripts/validate`, every `tests/test-*` and `claude plugin validate .` pass.
- A changed convention or a new decision is recorded in `docs/DECISIONS.md`, not in chat and
  not in commit messages alone.
- Commits follow Conventional Commits and carry no AI attribution line.
