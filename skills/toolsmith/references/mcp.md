# MCP recommendations

Read by `toolsmith` step 11. Context7 is installed by `init`. Everything else is proposed
here from the stack and the sources, and installed only on the user's yes, by
`init-workspace --add-mcp` (wrapper: the wrapper's `.mcp.json`; private mode: no file, a
`claude mcp add` line to run instead).

## Catalog

| Server | Propose when | Reason to give | After install |
|---|---|---|---|
| `playwright` | a frontend layer, or end-to-end tests with Playwright | drive the app in a browser for runtime checks and e2e debugging | approve it on first use; needs Node |
| `chrome-devtools` | a frontend layer, when performance or console debugging matters | console, network and performance traces from a real Chrome | needs Chrome and Node |
| `dbhub` | a backend or data layer with PostgreSQL, MySQL, MariaDB, SQL Server, Oracle or SQLite | inspect the schema and run read queries while designing and debugging | set `DATABASE_URL` in the shell that launches Claude Code (a development database, never production); the file holds only `${DATABASE_URL}` |
| `atlassian` | `sources.mcp` is `none` and the docs or the user name Jira or Confluence | fetch tickets with `/specd:start --from PROJ-123` | `/specd:config sources.mcp=atlassian`, then `/mcp` once to authorise |

- Propose `playwright` or `chrome-devtools`, not both, unless the user asks; `playwright`
  by default.
- Skip a server already present in `.mcp.json` (or, in private mode, one the user says is
  configured).
- A stack the catalog does not cover gets no proposal; say so in one line. Adding a server
  to the catalog is a change to `scripts/init-workspace`, not something to do in a run.

## The question

One multi-select question, one option per proposed server with its reason, plus "none".
For each selected server run `init-workspace --root <root> --add-mcp <name>` and show the
report. Private mode returns a `warnings` line with the `claude mcp add` command; print it
for the user to run. Then print the "After install" line for each.
