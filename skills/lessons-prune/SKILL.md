---
name: lessons-prune
description: >
  Invoke whenever the user asks to prune, clean up, trim or tidy `lessons.md`, says the
  lessons file is too long or over its cap, wants recurring lessons promoted into the
  conventions or a decision, follows the `status` warning about the lessons cap, or runs
  `/specd:lessons-prune`. It counts the file against `docs.lessons_max_lines`, flags
  near-duplicate and malformed lines with a script, proposes per lesson keep, promote (to
  `conventions.md` or a decision file), merge or delete, and applies only the rows you
  approve, then commits once. Not for adding a lesson; append the line yourself.
---

# Skill: lessons-prune

Keeps the always-loaded `lessons.md` small. A lesson is a holding item: one that recurs or
reads as a standing rule moves to where rules live, one that overlaps another is merged, one
that no longer applies goes. The script counts and applies; the main thread judges and asks.
A util per [`../_shared/utils.md`](../_shared/utils.md): no `state check`, nothing written
without a yes.

## Inputs

- `resolve-paths` ([`../_shared/paths.md`](../_shared/paths.md)).
- `<workspace_root>/specd.yml`: `docs.lessons_max_lines` (default 80), `git.authority`.
- `"${CLAUDE_PLUGIN_ROOT}/scripts/lessons" scan` output; `<docs_root>/lessons.md`.
- `<docs_root>/conventions.md` (its section headings and existing rules, to place a promotion
  and to spot lessons it already states).
- `<docs_root>/decisions/README.md` and the `NNNN-` file names in `<docs_root>/decisions/`
  (next number, titles), only when a decision is proposed.
- [`../_shared/templates/decision.md`](../_shared/templates/decision.md), and
  [`./references/proposals.md`](./references/proposals.md) (how each action is chosen).

## Outputs

- `<docs_root>/lessons.md`, changed only through `lessons apply`; the plan file it consumes
  is never committed.
- `<docs_root>/conventions.md`: one rule line per approved promotion there.
- `<docs_root>/decisions/NNNN-<kebab-title>.md` and its `decisions/README.md` row per
  approved promotion to a decision.
- One commit `docs(lessons-prune): <counts>` in the repo holding `<docs_root>`.

## Protocol

1. **Resolve.** `resolve-paths` (no config: `run /specd:init first`). Read the two keys.
2. **Scan.** `"${CLAUDE_PLUGIN_ROOT}/scripts/lessons" scan --file <docs_root>/lessons.md
   --max <docs.lessons_max_lines>`. Print `lessons.md: <lines>/<max> lines, <n> lessons,
   <d> duplicate pairs, <m> malformed`. No lessons and nothing malformed: say so, end with the
   handoff. Under the cap: ask once whether to review anyway; no → handoff.
3. **Read** `lessons.md` and `conventions.md`. Nothing else unless a decision is proposed.
4. **Propose** per [`./references/proposals.md`](./references/proposals.md). Print one table,
   every lesson and malformed line in file order:
   `L<line> · keep | promote→conventions:<section> | promote→decision | merge→L<n> |
   rewrite | delete · <reason, one line>`. Below it, the exact text each promotion, merge
   or rewrite would write. End with the projected count: `<lines> → <after>/<max>`. When the
   proposal still leaves the file over the cap, say so and name the oldest kept lessons.
5. **Ask** one question per `utils.md`: apply all, adjust, cancel. Adjust: apply the user's
   row changes (`L12 keep`, `L7 delete`), reprint the changed rows and the count, ask again.
   Cancel: handoff, nothing written.
6. **Promote** the approved promotions first, in the main thread:
   - conventions: append the rule line under the named section heading of `conventions.md`,
     as one line, in that file's style (rules only, no explanation);
   - decision: copy the template to `<docs_root>/decisions/NNNN-<kebab-title>.md` with the
     next free number, status accepted, today's date, context and consequences drafted from
     the lesson; drop the `specd:draft` line (the approval is the sign-off) and append the
     README row. A title already in the README is not written again; the lesson is deleted.
7. **Apply** the lesson lines: Write the plan as JSON to `<workspace_root>/.lessons-plan.json`
   (`[{line, expect, action, text}]`, one step per promoted, merged-away, deleted,
   merged-into or rewritten line; `expect` is the line exactly as scanned) and run `lessons
   apply --file <docs_root>/lessons.md --plan <that path> --max <max>`; the script deletes
   the plan on success. Never pass the JSON inline in the command. A refusal means the file
   moved: re-scan and go back to step 4. Never edit `lessons.md` with a file tool.
8. **Report** `before → after/max` from the script, and `over` when still true.
9. **Commit** per `utils.md`: `git -C <docs_root>` add the changed files by name, commit
   `docs(lessons-prune): promote p, merge m, rewrite r, delete d` (non-zero verbs only;
   `p` counts rules and decisions written, `m` merged lines kept, `r` and `d` lines).
10. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced`: the changed
    files. `Review`: each promotion's target, and `still over the cap` when it is.
    `State: lessons-prune`. `Next: none`, or the command the user was running.

## Anti-patterns

- Editing `lessons.md` with Edit or Write; the plan through the script is the only writer.
- Writing any row the user did not approve, or rewording a lesson they kept.
- Promoting into `project.md`, `CLAUDE.md` or an architecture file; rules go to
  `conventions.md`, reasons to a decision.
- Deleting a lesson only because it is old; age is a hint, not a reason.
- Asking one question per lesson; one table, one question.
