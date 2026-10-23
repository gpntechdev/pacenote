---
name: config
description: >
  Invoke whenever the user asks to change, set, show or check a specd setting (gate
  granularity, TDD, retention, PR host, ticket key, model roles, project commands, the
  ticket-source MCP server, specialist review passes, skill discovery, the skills
  allowlist and layers) or
  runs `/specd:config [key=value ...] [--add|--remove key=item]`. It reads `specd.yml`, shows the current value of the keys
  named (or the whole file when none), asks for the new values, patches them in place with
  `config-set` and shows `old -> new`. Not for creating the workspace; that is `/specd:init`.
---

# Skill: config

Changes settings in `specd.yml` after `init`, one or more keys per run. The only writer is
the `config-set` script, so comments, order and unknown keys survive and values land in their
documented form.

## Inputs

- `"${CLAUDE_PLUGIN_ROOT}/scripts/resolve-paths"` output: the config path.
- [`../_shared/specd-yml.md`](../_shared/specd-yml.md): every key, its values and who reads it.
- The arguments, if any: `key=value` pairs or bare key names.

## Outputs

- The patched `<workspace_root>/specd.yml`.
- No commit; the change rides with the next step's commit, or the user commits it.

## Protocol

1. **Resolve.** Run `resolve-paths`. No config: say `run /specd:init first` and stop.
2. **Show.** With bare key names or no arguments, print the current line for each key named
   (all keys when none), taken from the file as it is. Unknown key: name the closest keys
   from `specd-yml.md` and stop.
3. **Ask.** For each key without a value, ask for one, listing the documented values from the
   `Key semantics` table. Refuse a value outside that list before touching the file.
   List keys (`skills.allowlist`, `layers.<name>`) take `--add` or `--remove` with one
   item each, as `key=item`; a new layer name opens a new key. A documented key the file
   lacks (`git.wrapper_pr`, `flow.runtime_verify`, `commands.serve` on a file from before
   M7) is inserted by `config-set`. `sources.mcp` on a file from before M5 (`sources: []`):
   show the by-hand edit from `specd-yml.md` and stop.
4. **Patch.** Run `"${CLAUDE_PLUGIN_ROOT}/scripts/config-set" --file <config>` with every
   `key=value` in one call (list items: a second call with `--add` or `--remove`). Show its
   `old -> new` list verbatim. On refusal, show the
   script's message and stop; never repair the file by hand. `sources.mcp=atlassian`: ask
   whether to install the server into `.mcp.json`; on yes run
   `"${CLAUDE_PLUGIN_ROOT}/scripts/init-workspace" --root <root> --add-mcp atlassian`
   (root: `wrapper_root` from `resolve-paths`, or the repo holding `.specd/`) and show its
   report; say that `/mcp` authorises it once, interactively.
5. **Say when it applies.** `flow.gate_granularity`, `flow.critic`, `flow.specialists`,
   `flow.tdd`, `models.*` and `layers.*` take effect at the next step that reads them; a step
   already running keeps its values. `git.*` and `commands.*` apply immediately.
6. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md): `Produced` is the config
   path, `Next` is whatever the user was doing.

## Anti-patterns

- Editing `specd.yml` with a text tool; `config-set` is the only writer.
- Regenerating the file from the reference; unknown keys and comments would be lost.
- Changing a key the user did not name because it "looked wrong".
- Persuading the user to change a model role; roles are theirs to set.
