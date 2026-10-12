# Lens: performance

Read by the `specialist` agent for a performance pass. Judge against the sizes the spec or
the code implies; no micro-optimisation.

## Check

- Queries: one query per item in a loop (N+1), missing pagination or limits on lists that
  grow, filters or sorts on columns with no index, `SELECT *` on wide tables in hot paths.
- Migrations: locking or rewriting large tables, adding an index without the
  non-blocking form the database offers.
- Work in the request path that could be done once: repeated parsing, compiling,
  connecting or reading the same file.
- Memory: loading a whole table, file or response into memory where streaming or paging
  is the codebase's pattern.
- Caching: a new cache without invalidation, or a cache key that misses a parameter.
- Frontend when present: re-rendering on every keystroke without need, large imports in
  the main bundle, images without sizes, unbounded lists without virtualisation.
- Concurrency: sequential awaits that are independent, unbounded parallelism against an
  external service.

## Severity

Blocker: a path the spec calls hot gets asymptotically worse, or a migration would lock a
large table. Major: N+1 or an unbounded list on a path users hit. Minor: the rest.
