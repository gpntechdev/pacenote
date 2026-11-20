# Runtime: which assistant pacenote runs in, and what it can do there

**Reference-only.** Not a skill. pacenote is one plugin for Claude Code, Codex and Cursor
(DECISIONS 2026-11-19 M8). What differs between them is in the table below and nowhere
else: a skill asks `runtime` (or reads the same fields from `resolve-paths`), never tests
the assistant itself.

## Which assistant

`init` asks it once per person and writes `assistant:` to `pacenote.local.yml` next to
`pacenote.yml`. The file is gitignored, because teammates may use different assistants. A
missing key reads as `claude` when `CLAUDECODE` is set in the environment, else as
`unknown`. `unknown` gets the most restrictive row. `runtime --suggest` guesses from the
environment and gives `init` its recommended answer. It is only a guess.

## The table

`fenced_agents`: the runtime runs an agent with only the tools its definition lists.
Hostile text (fetched pages, tickets, third-party skills) is read only by such an agent.
`command`: how a step is invoked (`{step}` is the skill name). `memory`: the project memory
file `init` points at `docs/`. `mcp_file`: where `init` writes MCP servers (relative to the
repo root, or the wrapper root). `skill_home`: where `toolsmith` installs project skills.
`dispatch`: how a skill runs one of the plugin's agents (below). `models`: the role
defaults `init` writes to `pacenote.local.yml` (`null` = `pacenote.yml`'s).

```json
{
  "claude": {"fenced_agents": true, "command": "/pacenote:{step}", "memory": "CLAUDE.md",
             "mcp_file": ".mcp.json", "skill_home": ".claude/skills", "dispatch": "named",
             "models": null},
  "codex":  {"fenced_agents": false, "command": "$pacenote:{step}", "memory": "AGENTS.md",
             "mcp_file": ".codex/config.toml", "skill_home": ".agents/skills",
             "dispatch": "inline",
             "models": {"judgment": "gpt-6.2-astra", "execution": "gpt-6.2-sol",
                        "cheap": "gpt-6.1-terra"}},
  "cursor": {"fenced_agents": false, "command": "/{step}", "memory": "AGENTS.md",
             "mcp_file": ".cursor/mcp.json", "skill_home": ".agents/skills",
             "dispatch": "named",
             "models": {"judgment": "inherit", "execution": "inherit", "cheap": "inherit"}},
  "unknown": {"fenced_agents": false, "command": "/pacenote:{step}", "memory": "AGENTS.md",
              "mcp_file": ".mcp.json", "skill_home": ".agents/skills", "dispatch": "inline",
              "models": null}
}
```

Codex and Cursor rows are taken from the docs and an offline probe, not from a live run
(DECISIONS 2026-11-19 M8). `fenced_agents` flips to `true` there only after a live probe
shows a read-only agent that cannot act.

## Dispatching an agent

The agents live once, in the plugin's `agents/<name>.md`. When a skill says "dispatch
`<name>` at `models.<role>`":
- `named`: start the plugin agent `pacenote:<name>` with the model from `resolve-paths`'
  `models`. If the runtime lists no such agent, dispatch inline instead.
- `inline`: read `../../agents/<name>.md` (relative to the folder of the `SKILL.md` being
  followed, like scripts). Start a subagent with the model from `models`, and give it the
  file's body (below the frontmatter) followed by the skill's prompt. Its `tools:` line
  is a rule the subagent is told to keep, not a fence.

Codex loads no plugin agents (DECISIONS 2026-11-19 M8), so it dispatches inline. That is
also why `fenced_agents` is false there.

## Fail closed

Where `fenced_agents` is false, three actions are off: a URL `start` (`--from <url>`), a
ticket or MCP fetch, and a third-party `toolsmith` candidate (search, fetch or a local
folder). `fetch-source` and `skill-fetch` refuse on their own. A skill about to dispatch
`intake` for a ticket runs `runtime --from <workspace_root> --require fenced_agents --action
mcp` first. On exit 1, the skill prints the script's one line as it is and goes on as the line
says: ask for a paste, or generate the skill. The line is:

```
pacenote: <assistant> cannot fence an agent's tools, so <action> is off here (fail closed); <fallback>.
```

Files and pastes are the user's own text and work everywhere.
