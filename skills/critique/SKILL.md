---
name: critique
description: >
  Invoke whenever the user asks for a critique, a devil's-advocate read, the holes, the
  ambiguities or the hidden assumptions in a spec, design or any document, or runs
  `/pacenote:critique <path>`. It dispatches the critic agent in a fresh context over that one
  file (plus the project summary, and the spec when the file is a design) and prints at most
  ten ranked findings with the question that resolves each. It writes nothing and works
  whatever `flow.critic` says; the owning step folds the findings in when you re-run it.
  Not for reviewing code; that is `/pacenote:review`.
---

# Skill: critique

The critic on demand. Inside the flow it runs before G1 and G2 by itself
([`../_shared/critic.md`](../_shared/critic.md)); this command runs the same agent on any
file at any time, including a document outside the spec folder, and leaves folding to you.

## Inputs

- `resolve-paths` (for `<docs_root>/project.md` and the spec root).
- The argument: a path to one markdown or text file, relative to the current directory or
  absolute. None given: ask for one.
- `<spec_root>/<feature>/spec.md` when the argument is a feature's `design.md`.
- `<workspace_root>/pacenote.yml`: `models.judgment`.
- [`../_shared/critic.md`](../_shared/critic.md) (dispatch prompt and answer shape).

## Outputs

- None on disk. The findings are printed.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /pacenote:init first`). The file must exist
   and be readable; a secret-looking path is refused. Say in one line what the critic will
   read: the file, `project.md` when present, and `spec.md` when the file is a design.
2. **Dispatch** `critic` at `models.judgment` with the prompt in `critic.md`, the paths
   absolute. Never add the conversation or other files.
3. **Print** the findings verbatim as they came back, `C1..` ranked, or `critic: no
   findings`. Do not resolve, rank again, or comment on them.
4. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced: none`.
   `Review`: the findings. `Next`: the step that owns the file when it is a feature
   artifact (`/pacenote:specify <feature>` for `spec.md`, `/pacenote:design <feature>` for
   `design.md`, with one line saying a re-run clears the later gates), else `none`.

## Anti-patterns

- Editing the file, even to append the findings; the owning step does that at its gate.
- Running it on a code file or a diff; the critic reads prose, `review` reads code.
- Pasting the file into the prompt; the agent reads the path itself.
- Softening or dropping a finding before printing it.
