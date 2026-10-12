---
name: init
description: >
  Invoke whenever the user asks to set up, initialise, install or configure specd (or "the
  workflow") in a repository or around one, or runs `/specd:init [--wrapper [<folder|url>]]`.
  It does the mechanical setup only: picks embedded (inside the repo) or wrapper (your own
  repo around a client repo that must get no files), detects greenfield or brownfield, git
  host, ticket convention and project commands with scripts, asks a short interview
  (retention, TDD, gate granularity, PR host, private mode; wrapper: where docs land), then
  writes `specd.yml`, the no-attribution setting, `.mcp.json` with Context7 and a pointer
  block in `CLAUDE.md`, and commits. It writes no project knowledge; that is
  `/specd:onboard`, which it hands off to.
---

# Skill: init

Creates the specd workspace. Everything it writes is either a verbatim copy of a reference
file or the answer to a question; nothing is generated from a scan of the code. Two modes,
one script: embedded puts the workspace in `<repo>/.specd/`; wrapper puts it at the root of
the user's own repo around the code repo ([`./references/wrapper.md`](./references/wrapper.md)).

## Inputs

- The current directory (the repository, a folder inside it, or the wrapper folder) and the
  arguments: `--wrapper [<folder|url>]`.
- [`../_shared/specd-yml.md`](../_shared/specd-yml.md): the config file the script copies.
- [`../_shared/no-attribution.md`](../_shared/no-attribution.md): the setting the script merges.
- [`../_shared/paths.md`](../_shared/paths.md): what the roots mean.
- `./templates/CLAUDE.md` and `./templates/lessons.md`, rendered by the script.
- [`./references/wrapper.md`](./references/wrapper.md): the wrapper-mode delta.

## Outputs

- Embedded: `<repo>/.specd/specd.yml`, `<repo>/.specd/docs/` (with `lessons.md`),
  `<repo>/.specd/spec/`, `<repo>/.specd/sources/`; `<repo>/.claude/settings.json`
  (attribution off), `<repo>/.mcp.json` (Context7), `<repo>/CLAUDE.md` pointer block between
  `<!-- specd:begin -->` and `<!-- specd:end -->`.
- Private mode instead: `CLAUDE.local.md`, `.claude/settings.local.json`, three lines in
  `.git/info/exclude`, no `.mcp.json`.
- Wrapper: the same files at the wrapper root, `docs/` where the user chose, `.gitignore`
  with the code folder and `.worktrees/`; nothing in the code repo.
- One commit `chore: initialise specd workspace` (none in private mode).

## Protocol

1. **Refuse a second init.** Run `"${CLAUDE_PLUGIN_ROOT}/scripts/resolve-paths"`. If it finds
   a config, say `already initialised at <config>; use /specd:config to change settings` and
   end with the handoff block.
2. **Detect and pick the mode.** Run `"${CLAUDE_PLUGIN_ROOT}/scripts/detect-repo"`. Decide
   the mode per `wrapper.md` ("Deciding the mode"); wrapper: settle the code repo and run
   `detect-repo` and `detect-commands` again with `--from <code>`. Embedded: run
   `detect-commands`. If the workspace repo's `git` is false, ask whether to run `git init`;
   on no, stop. Keep the JSON results; they answer most of the interview.
3. **Interview**, one grouped question set with defaults prefilled, nothing that detection
   already answered:
   - retention for full-tier features: `distill` (default) / `clean` / `keep`;
   - TDD: off (default) / on;
   - gate granularity for implementation: `phase` (default) / `task` / `end`;
   - PR host: prefilled from `remote_host`; ask only when it is `none`;
   - ticket key: ask only when `ticket_key` is empty ("none" is a valid answer);
   - embedded: private mode, no (default) / yes, for a repo whose team should not see specd
     files; wrapper: where `docs/` lands (`wrapper.md`, "Interview").
4. **Create.** Run `"${CLAUDE_PLUGIN_ROOT}/scripts/init-workspace" --root <root> [--private]`
   (wrapper: `--mode wrapper --code <name> [--docs <name>/docs]`). Show its `created`,
   `merged`, `skipped` and `warnings` lists as they came back.
5. **Configure.** Run `"${CLAUDE_PLUGIN_ROOT}/scripts/config-set" --file <config>` with the
   interview answers and the derived values: `project` (from `project_name`), `git.pr_host`,
   `git.ticket_key`, each non-empty `commands.*` from `detect-commands`, and in wrapper mode
   `mode`, `paths.code_root` and `paths.docs_root` (`wrapper.md`). Show the `old -> new`
   list; mark derived values so the user can correct them with `/specd:config`.
6. **Commit** (skip in private mode): stage exactly the paths the script created or merged
   plus `CLAUDE.md`, commit `chore: initialise specd workspace` on the current branch of the
   workspace repo, no attribution line; wrapper with docs in the code repo: the second
   commit `wrapper.md` names.
7. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Next`: `/specd:onboard`.
   Greenfield: add a second line "then `/specd:scaffold` once the architecture section is
   signed off". Wrapper: the two lines from `wrapper.md` ("Handoff additions"). Last line:
   "project skills and MCP recommendations come with `/specd:toolsmith`, not yet available".

## Anti-patterns

- Regenerating or hand-editing `specd.yml`; `config-set` is the only writer.
- Putting knowledge into the CLAUDE.md block; it points at `<docs_root>/`, nothing more.
- Reading source files to "get a feel" for the repo; `detect-repo` already counted them.
- Asking a question whose answer is in the detection output.
- Committing files the script did not touch, or anything in a wrapped code repo beyond the
  docs folder the user sent there.
- Describing the wrapper's own folder from its `detect-repo` output; the code repo's
  detection is the one that matters.
