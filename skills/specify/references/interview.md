# The specify interview

Rules first, then the question families per section, then the acceptance-criterion forms.
Use the assistant's question tool with concrete options when one exists; otherwise ask in
prose, one topic at a time.

## Rules

- Ask only what the brief, the docs and the sources do not answer. Never re-ask something the
  brief states; quote it back and ask only if it conflicts with the code or the docs.
- At most four questions per round, each about one section, defaults prefilled from the brief.
  At most three rounds. After that, every leftover is an open question with an owner.
- Write each answer into `spec.md` as it arrives; the file is the state, not the chat.
- When the user answers with a source ("see the ticket comments", "here is the RFC"), snapshot
  it per [`../../_shared/sources.md`](../../_shared/sources.md) and read that.
- "Don't know" and "ask <person>" are answers: open question, owner, blocks which AC.
- The tier from `state.yml` sets the depth: trivial and quick stop after round one unless an
  AC is still unverifiable; full may use all three rounds.

## Research

When an open question is an external fact (a supported version, the recommended way to do
X in a named library, a documented limit), offer "research it" as one option of its
question. On yes, dispatch `researcher` per
[`../../_shared/research.md`](../../_shared/research.md) (at most three per run), append
the answer to `research.md` in the feature folder, and rewrite the open question with the
finding, its URL and `seen` date, or turn it into an AC when the fact settles it. The user
still picks; a finding is evidence, not the answer. Both files ride the step's commit.

## Question families

| Section | Ask about |
|---|---|
| Problem | who is affected, what they do today instead, what changes if nothing is done |
| Scope | the smallest version that solves the problem; what the user expects to see first |
| Out of scope | the adjacent things the input hints at (related pages, other roles, migrations of old data) |
| Acceptance criteria | inputs, the visible result, the error paths, limits and sizes, permissions |
| Open questions | who decides the unresolved ones, by when, and whether it blocks an AC |

## Acceptance-criterion forms

An AC is one of these, and nothing else:

- **Behaviour**: `given <state>, when <action>, then <observable result>`. The result is
  something a test can assert: a response, a record, a message, a file.
- **Command**: `<command> exits 0 and <prints or produces X>`. Used for tooling and scripts.
- **Manual**: `manual: <what a person checks and what they must see>`. Only when no test or
  command can show it (visual layout, a third-party console). `verify` asks for the note.

Rewrite until each AC has no "should", "properly", "fast", "correctly" or "user-friendly".
Numbers replace adjectives: "under 300 ms at p95", "at most 20 rows". An AC that names two
behaviours is two ACs. An error path the user cares about is its own AC.
