---
name: runtime-verify
description: >
  Invoke whenever the user asks to check the feature in the running app, exercise the
  acceptance criteria against a live server or in a browser, smoke-test the endpoints or
  pages for real, or runs `/pacenote:runtime-verify [feature]`; also as the next step after
  `/pacenote:verify` when the feature switched it on. It starts the app (`commands.serve`),
  runs HTTP checks per AC through a script and browser checks through the
  `runtime-verifier` agent and the playwright MCP server, stops the app, writes
  `runtime.md` and appends `runtime:` evidence to the coverage matrix in `tasks.md`.
  Full tier only. Not for unit or integration tests; those are verify.
---

# Skill: runtime-verify

The optional step between `verify` and `docs`: what the tests claim, seen in the running
app. Evidence is a request that got its answer or a page that showed its text, run today.
Nothing reaches the main thread but the script's JSON and the agent's bounded answer.

## Gate

`state check --step runtime-verify`: full tier, `runtime_verify: on` in `state.yml` (set by
`verify`'s question) and `step` at `runtime-verify` or later. Off, the step is not in the
flow and the check names the step that is.

## Inputs

- `resolve-paths`, `state find`, `state check`, `detect-repo`, `runtime-check`.
- `<spec_root>/<feature>/spec.md` (ACs), `tasks.md` (matrix), `design.md` when present
  (`API and contracts`, `UX flows`), `state.yml`.
- `<workspace_root>/pacenote.yml`: `commands.serve`, `commands.serve_url`, `models.execution`,
  `git.authority`. `.mcp.json` at the MCP root (`wrapper_root` from `resolve-paths`, or the
  repo holding `.pacenote/`): is `playwright` there.
- `<docs_root>/project.md` (how to run, to suggest a serve command); route and page names
  looked up in `<code_root>` per `checks.md`.
- [`./references/checks.md`](./references/checks.md), [`../_shared/paths.md`](../_shared/paths.md),
  [`../_shared/gates.md`](../_shared/gates.md), [`../_shared/state-yml.md`](../_shared/state-yml.md).

## Outputs

- `<spec_root>/<feature>/runtime.md` (replaced each run); `runtime:` parts in the matrix
  Evidence cells; on failures, tasks under `Runtime fixes` in `tasks.md`.
- `state.yml`: `step` (`docs`, or `deliver` on a PR; `implement` when fixes were added).
- `commands.serve` / `serve_url` in `pacenote.yml` when the user agreed to save them.
- One commit `spec(<feature>): runtime-verify` (authority ≠ `none`).

## Protocol

1. **Resolve** per `paths.md` ("Resolving for a feature"), `state check --step
   runtime-verify` per `gates.md`. Set `step=runtime-verify`.
2. **Serve.** Read `commands.serve` and `commands.serve_url`. Either empty: one question
   with a suggestion from `project.md` (how to run) — the command, run in `<code_root>`, and
   the URL it answers on; or "already running at <URL>" with no command. Then offer once to
   save both with `"${CLAUDE_PLUGIN_ROOT}/scripts/config-set" --file
   <workspace_root>/pacenote.yml commands.serve=<cmd> commands.serve_url=<url>`. A URL whose
   host is not `localhost`, `127.0.0.1`, `[::1]` or `*.local`: confirm it is not production
   before going on, since checks may write data.
3. **Plan.** Classify every AC `http`, `browser` or `none` and draft the checks per
   `checks.md`. Show the proposal table; one question: run all, adjust (rows to change or
   skip, in free text; reprint and ask again), or cancel (step stays, handoff names it).
   Ask on every run, a re-run included, and wait for the answer: the checks start a
   process and send requests that may write data.
   Browser rows with no `playwright` server in `.mcp.json`: the same question offers
   installing it (`init-workspace --root <MCP root> --add-mcp playwright`; the server
   loads only after Claude Code restarts, so this run treats those rows as skipped and the
   handoff says to re-run), attesting by a manual note as `verify` does, or skipping.
4. **Start.** `"${CLAUDE_PLUGIN_ROOT}/scripts/runtime-check" start --serve <cmd> --url
   <url> --cwd <code_root> --state-dir <workspace_root>/.runtime`, every path absolute
   (no `$PWD`). Status `exited` or
   `timeout`: show the log tail; no evidence is written; handoff `Next:
   /pacenote:runtime-verify <feature>` after fixing the command (`/pacenote:config`) or the app
   (`/pacenote:implement <feature>`). `reused`: the app was already up and is left running.
5. **HTTP.** Write the `http` rows to `<workspace_root>/.runtime/plan.json` with the Write
   tool, then `runtime-check run --plan <that file> --url <url>`. Read only its JSON.
6. **Browser.** Dispatch one `runtime-verifier` at `models.execution` with the prompt in
   `checks.md` for all `browser` rows. Never call the playwright tools from the main
   thread. An answer missing an AC counts that AC as `blocked`. Note first whether
   `<MCP root>/.playwright-mcp/` exists; the server writes page snapshots and console logs
   there.
7. **Stop.** `runtime-check stop --state-dir <workspace_root>/.runtime`, always, including
   after a failure in 5 or 6. Remove `<MCP root>/.playwright-mcp/` when step 6 created it.
8. **Record** per `checks.md` ("Writing back"): `runtime.md` from
   `./templates/runtime.md`, `runtime:` parts on passed rows. Each `fail` or `blocked` AC:
   one grouped question per AC — add a fix task (append to `tasks.md` under `Runtime fixes`
   with a new id, `covers` the AC, a `commit:` line; `state set tasks.T<k>=todo
   step=implement`) or accept with a reason written into the cell.
9. **Commit.** No fix task: `state set step=next`. `git -C <workspace_root>` add
   `runtime.md`, `tasks.md`, `state.yml`, `pacenote.yml` when step 2 saved it and `.mcp.json`
   when step 3 installed playwright (its own repo's commit when that is another repo);
   commit `spec(<feature>): runtime-verify`.
10. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Review`: failed,
    blocked and accepted ACs, `none` rows worth a manual look, a server that was reused.
    `Next: /pacenote:<step> <feature>` with the step the script reports.

## Anti-patterns

- `curl`, WebFetch or a browser MCP tool in the main thread; the script and the agent are
  the only callers, so responses and pages stay bounded.
- Running the checks on a proposal the user has not answered in this run.
- Leaving a server running that this step started; step 7 runs whatever happened.
- A `runtime:` pass for an AC that did not run, or copied from test results.
- A request or a page outside `commands.serve_url`'s origin, or a production URL.
- Real credentials in the plan or the prompt; a test account the user names is the limit.
- Committing `.runtime/` (it ignores itself) or a screenshot.
