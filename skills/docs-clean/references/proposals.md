# Choosing an action per finding

How `docs-clean` step 4 picks one action per finding. Inputs: the `docs-clean scan` JSON, the
over-cap files and the READMEs with findings. One action per finding; the default comes
first, the alternatives are what an adjust round may pick.

| Check | Kind | Default | Alternatives | Writes |
|---|---|---|---|---|
| pointers | `drifted` or `out_of_range` with `suggest` | `repoint` | `report`, `delete line` | the line with the new `path:line` |
| pointers | without `suggest` (`missing`, or no single hit) | `report` | `delete line`, the user's own pointer | nothing, or the user's line |
| links | `broken` with `suggest` | `relink` | `unlink`, `report` | the line with the new target |
| links | `broken` without `suggest` | `unlink` | `report`, the user's own target | the line with that link turned into its plain text |
| caps | `over` | `trim` | `report` | the whole file, trimmed |
| drafts | `draft` | `leave` | `sign-off` | nothing, or line 1 deleted |
| readmes | `missing_row` | `sync` | `report` | one row, inserted in order |
| readmes | `stale_row` | `sync` | `report` | the row deleted |
| readmes | `no_readme` | `sync` | `report` | the README from its template, one row per file |
| sources | `unlinked` | `delete` | `keep` | the snapshot removed; git history keeps it |

A `suggest` covers every pointer or link on its line, so several findings on one line become
one plan step; count each finding in the commit.

## Text rules

- **Pointers and links.** Use the script's `suggest` verbatim. A user-given pointer or target
  replaces only that token; the rest of the line stays.
- **Trim.** Bring the file to its cap or under, by the contract in its template's header
  comment: keep facts, pointers and rules; drop narration, history ("added in feature X"),
  restated content another doc holds (link it instead), and empty or placeholder sections.
  Never drop a section heading the template fixes (`architecture/overview.md` headings are
  read by `scaffold`). A feature record over 150 lines first loses verbatim diagrams that
  repeat each other, then `Where it lives` rows for tests and config. A decision over 40
  lines keeps Context, Decision and Consequences, each shorter. Pointer and link findings
  inside the file are fixed in the same text. If the file cannot reach its cap without losing
  facts, say so and propose `report`, naming the split (an area or domain file per
  aggregate, per `onboard`).
- **Draft.** `leave` names `/specd:onboard <section>` (the scan's `section`); an empty
  section means a file `onboard` does not own, which the proposal says. Propose `sign-off`
  as the default only when the user says the section is finished; never because the file
  looks complete.
- **README rows.** One line, in the README's own column order and the link style of its
  existing rows. Features: the stem (linked to `./<stem>.md`), what it does (the record's
  first sentence), the entry point (from the record) and the `Shipped` date, inserted by
  date. Decisions: `| <NNNN> | <title without the number> | <Date> | <Status> |` from the
  scan's `title`, `date` and `status`, inserted by number.
  Insert after the row it follows (`insert`, `line` = that row; the separator row when it
  goes first). A cell the record does not state is `unknown`, never guessed.
- **New README.** Copy [`decisions-README.md`](../../onboard/templates/decisions-README.md)
  or [`features-README.md`](../../docs/templates/features-README.md) without its draft
  marker and comment, then the rows as above.
- **Sources.** The reason names `title`, `origin` and `via` from the scan. An `http` or
  `mcp:*` snapshot can be fetched again; a `paste` or `file` one cannot, so say so in its
  reason: the user may prefer `keep`.
