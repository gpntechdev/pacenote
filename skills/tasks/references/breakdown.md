# Breaking a feature into tasks

## Size and order

- A task is at most a day of work and touches one concern: one module, one migration, one
  endpoint, one screen. If listing its `files` takes more than five lines, split it.
- Order by dependency, not by design section: what must exist first comes first. Phases
  group tasks that can be reviewed together at a G4 stop: `Foundations` (schema, contracts,
  helpers), `Behaviour` (the feature itself), `Edges` (error paths, limits, permissions),
  `Verify`. Use the names the feature needs; keep `Verify` last.
- Between two and twelve tasks is the norm. One task means the tier should have been
  trivial; more than twelve means the spec is two features.

## Heavy tasks

- A task block is inline in `tasks.md` by default, whatever the file's total length;
  `implement` reads the file once per run and dispatches one block at a time.
- A task whose body would pass about 100 lines (a long tests block, many files, a
  multi-step done-when) costs that much on every run that reads the file. First ask whether
  it is really one unit: the sizing rules above usually say it is two tasks. When it is one
  unit, write its body to `tasks/T<n>.md` from `templates/task.md` and keep only the index
  line in `tasks.md`: `- T<n> · <goal> · risk <low|high> · covers <ACs> · tasks/T<n>.md`.
- Readers recognise an externalised task by its entry being an index line ending in
  `tasks/T<n>.md`, never by the folder existing; light and heavy tasks sit side by side.
- Review-fix tasks follow the same rule: inline unless the fix is heavy.

## done-when forms

- A command: `<test command> -k <name> passes`, `<lint command> exits 0`, `curl … returns 201`.
- An observable: "`GET /items/1` returns the record created by T2", "the migration applies
  and rolls back on an empty database", "the screen renders the empty state from AC4".
- Never "code is written", "works as expected" or "reviewed".

## risk

Mark `risk: high` when the task: changes or deletes persisted data or a migration; touches
auth, permissions, payments or secrets; changes a public contract other code depends on;
removes code; or runs anything against an external system. High-risk tasks always stop for
G4 (`gates.md`), whatever the granularity.

## layer

- `pacenote.yml` `layers` maps a layer name (`frontend`, `backend`, `infra`, `data`, whatever
  the project uses) to the project skill files `implement` hands the implementer for tasks
  of that layer. When the map is non-empty, every task that touches one of its layers names
  it in `layer:`; a task that needs two layers is two tasks (the one-concern rule above).
- Omit the line when the map is empty or the task touches no listed layer. Never invent a
  name that is not a key of the map; the Verify task has no layer.

## commit

One Conventional Commit message per task, fixed here so `implement` never invents one:
`<type>(<scope>): <summary>`, imperative, no period, type from `feat`, `fix`, `test`,
`refactor`, `chore`, `docs`; scope per `conventions.md` when it names scopes, else the
module. `commit: none` only for the Verify task.

## covers and the matrix

- `covers` lists the AC ids the task makes true. A prerequisite task with no AC of its own
  lists the AC of the task that needs it, with `(via T<n>)`.
- The matrix has exactly one row per AC in `spec.md`; every row names at least one task.
  The Test column names the test case (TDD on), the check that proves it (`lint`, `typecheck`,
  a command) or `manual` for ACs written as `manual:` in the spec.
- `verify` writes Evidence; leave it empty here.

## tests block (TDD on)

- One case per behaviour in the covered ACs, named the way the project names tests
  (`conventions.md`, else the test framework's convention): what it asserts, not how.
- Error paths from the ACs get their own case. The Verify task has no tests block.
- `implement` writes these cases first and watches them fail before writing code.
