# Principles

**Reference-only.** Not a skill. Loaded by `/pacenote:principles` and referenced by every skill
that writes code. Owned by the plugin; changes are recorded in `docs/DECISIONS.md`.

Stack-agnostic and permanent. They apply to code, tests, scripts, docs and configuration alike.

## 1. Think before coding

- Restate the goal in one sentence before touching anything. If you cannot, you do not
  understand the task yet.
- List the assumptions you are making. An unstated assumption is a bug waiting for a reviewer.
- When the request is ambiguous and the readings lead to different work, ask one question with
  concrete options. Otherwise pick the reading a careful colleague would, and say which.
- Name the done-when: the observable result that proves the task is complete (a passing test,
  a command's output, a file in a given state).
- Read the code you are about to change and its callers before editing. Reuse what exists;
  do not write a second utility for the same job.

## 2. Simplicity first

- Build the minimal thing that solves the exact problem asked. Not the general version, not
  the configurable version, not the one the next feature might need.
- No speculative features (YAGNI). If nobody asked for it, it does not exist.
- No single-use abstractions. A helper, interface, base class or config knob earns its place
  on the third caller, not the first.
- Prefer the boring solution (KISS): plain functions over frameworks, data over indirection,
  the standard library over a dependency.
- Fewer moving parts beat cleverness. If a reader needs a comment to follow it, simplify it
  instead of commenting it.

## 3. Surgical changes

- Touch only what the task needs. Every changed line must trace back to the goal.
- Match the existing style: naming, formatting, error handling, test layout. Consistency
  beats preference.
- No drive-by refactors, renames or reformatting. Note them for a separate task.
- Leave unrelated code, comments and whitespace untouched so the diff reads as the change.
- Remove what you make dead. Never leave commented-out code or unused imports behind.

## 4. Goal-driven execution

- Work from the done-when. Each step either moves toward it or is not done.
- Verify before claiming done: run the test, the command, the check. "Should work" is not done.
- Report honestly: what was verified, what was not, what was skipped and why. A failing test
  is reported as failing, with its output.
- Stop when the goal is met. Do not keep polishing, extending or fixing "while I'm here".
- When blocked, finish everything that does not depend on the block, then say exactly what
  blocks and what is needed.

## 5. Clean code and architecture

- Names say what a thing is or does; a reader should not need to open it to know.
- Small units with one responsibility. A function that needs section comments is two functions.
- Explicit boundaries: a module exposes a deliberate interface and hides the rest.
- Dependencies point inward: domain logic does not import frameworks, I/O or transport details.
- Don't repeat yourself, with the rule of three: tolerate a second copy, extract on the third.
- Errors are handled where they can be handled and surfaced with context where they cannot,
  never swallowed.
- Tests describe behaviour, run fast, and fail for one reason.

## Self-check before reporting done

1. Can I state the goal and the done-when in one sentence each?
2. Did I list my assumptions, and ask when the readings diverged?
3. Is this the smallest change that meets the goal, with nothing speculative?
4. Does every changed line trace to the task, in the existing style?
5. Did I run the verification and report the actual result?
6. Would a reviewer understand the change from the diff alone?
