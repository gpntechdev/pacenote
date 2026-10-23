---
name: principles
description: >
  Invoke first, before any tool call, whenever the user asks to write, add, build, implement,
  change, fix, refactor, clean up or review code, tests, scripts or configuration in any language
  or stack, however small the task. It sets the working method (restate the goal and done-when,
  state assumptions, minimal surgical change, verify before reporting) and produces no files.
  Also on `/pacenote:principles`. Skip only for questions that change nothing.
---

# Skill: principles

Sets how code is written. Produces no artifact. Every pacenote skill that writes code
(`implement`, `fix`, `scaffold`) applies this block; it also runs on its own for any coding
request outside the flow.

## Inputs

- The request as given.
- [`../_shared/principles.md`](../_shared/principles.md): the canonical principles. Read it now.

## Outputs

- None on disk. The result is the way the task is carried out and reported.

## Protocol

1. **Restate.** One sentence for the goal, one for the done-when (the observable proof).
2. **Assume or ask.** List the assumptions you are making. If two readings lead to materially
   different work, ask one question with concrete options; otherwise state the reading and go.
3. **Plan the minimal change.** Name the files to touch and the existing code to reuse. Reject
   anything not needed for the done-when.
4. **Implement surgically.** Change only those files, in their existing style. Note refactors
   you resisted for a follow-up instead of doing them.
5. **Verify and report.** Run the check that proves the done-when. Report what was verified,
   what was not, and the actual output of anything that failed. Run the self-check at the end
   of `principles.md` before saying done.

## Anti-patterns

- Starting to edit before the goal is restated.
- Adding a parameter, option or abstraction "for later".
- Reformatting or renaming outside the task.
- Saying "should work" instead of running it.
