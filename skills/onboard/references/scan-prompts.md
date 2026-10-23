# Explorer prompts per section (brownfield)

One `explorer` run per section. Fill the placeholders from `resolve-paths` and `detect-repo`
output, pass the section's checklist questions verbatim, and dispatch at the `cheap` model role
(read `models.cheap` from `pacenote.yml` and pass it as the agent's model). Never run the scan in
the main thread.

## Common header

```
Root: <code_root> (absolute). Read: <read globs>. Skip: .git, node_modules, vendor, dist, build,
target, .venv, venv, __pycache__, coverage, .next, .pacenote, .env*, *.pem, *.key, credentials*.
Existing docs to read first, never to rewrite: <paths from detect-repo: CLAUDE.md, AGENTS.md,
README.md, docs dirs>.
Answer in the fixed four-section shape from your instructions, at most 80 lines.
Questions:
<checklist questions for the section, one per line>
```

## project

Read globs: `README*`, `CLAUDE.md`, `AGENTS.md`, `docs/**/*.md`, root manifests
(`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `Gemfile`,
`composer.json`, `Makefile`), CI config (`.github/workflows/*`, `.gitlab-ci.yml`), the top two
directory levels (names only). Add to the header: "Commands are already detected; confirm them
only if the docs contradict the manifests." Pass the `detect-commands` output as a data block.

## Map pass and item pass

Architecture (areas) and data-models (domains) are an index plus one file per item. On a
repo with more than five items a single run cannot cover them, so the section runs in
passes: a **map pass** that lists the items, then **item passes** that fill at most five
files per run. Five items or fewer: one run does both.

Map pass header addition: "List every <area|domain> once: name, folder, and a count of
<entry points|entities>. No detail beyond one clause per item. Stop at the list."

Item pass: one explorer run per item with the section's read globs narrowed to that item's
folder and the item template's headings as the questions. Header addition: "Answer only for
<item> at <folder>. Give `path:line` pointers, never field lists or code."

## architecture

Read globs: the source roots (from `project.md` layout, else `src/**`, `app/**`, `lib/**`,
`cmd/**`, `internal/**`, `pkg/**`), entry points (`main.*`, `index.*`, `app.*`, `server.*`,
`cmd/*`), routing and wiring files, `docs/**/*.md` mentioning architecture or ADR. Add to the
header: "Name every area once before going deep. For key flows, give the entry `path:line` and
the areas it passes through, not the code."

## conventions

Read globs: linter and formatter configs (`.eslintrc*`, `eslint.config.*`, `.prettierrc*`,
`ruff.toml`, `pyproject.toml`, `.golangci.yml`, `rustfmt.toml`, `.rubocop.yml`,
`.editorconfig`), `CONTRIBUTING*`, PR and issue templates, git hooks config (`.husky/**`,
`.pre-commit-config.yaml`, `lefthook.yml`), a sample of ten source files and ten test files
chosen across areas. Add to the header: "Report rules that are enforced by a tool separately
from rules that are only followed by habit; give one `path:line` example for each habit."

## data-models

Read globs: ORM models and schema files (`**/models/**`, `**/entities/**`, `**/schema*`,
`prisma/**`, `**/migrations/**`, `*.sql`, `**/*.proto`, `**/db/**`). Add to the header: "If
none of these exist, answer D1 with 'no persisted data models' and stop after the checklist.
Group entities by domain (schema, module or folder). Report entity names with `path:line`,
never their fields. A domain past fifteen entities: name the aggregate roots and say 'and N
more in <folder>'."

## decisions

Read globs: `docs/**/adr*/**`, `docs/**/decisions/**`, `**/ADR*`, `**/DECISIONS*`,
`docs/**/*.md` containing "decision" or "we chose", top-level config files that encode a
choice (monorepo tool, build tool, framework). Add to the header: "For R2, list at most five
visible choices with no recorded reason; the user decides which to record."
