# Choosing an action per lesson

How `lessons-prune` step 4 picks one action per line. Inputs: the `lessons scan` JSON, the
text of `lessons.md` and `conventions.md`. One action per line; when two fit, take the first
in this order.

| Action | When | Writes |
|---|---|---|
| `delete` | `conventions.md` already states the rule (same meaning, any wording); or the lesson names a file, tool, flag or feature that no longer applies as far as `conventions.md` shows; or it was a one-off about a single feature with no rule to carry forward | nothing; the line goes |
| `promote→decision` | The rule only makes sense with its reason, the choice could reasonably go another way, and a later feature would want to know why (the durability test in `skills/docs/references/distill.md`) | a decision file + README row; the line goes |
| `promote→conventions:<section>` | The rule is general and stands alone in one line, and either recurs (a `duplicates` pair, or two lessons with the same context and the same point) or reads as a standing project rule rather than a one-time correction | one rule line under the section; every line it came from goes |
| `merge→L<n>` | A `duplicates` pair, or same context and same point, and the rule is not yet a standing convention | `L<n>` becomes the merged line; the others go |
| `rewrite` | A `malformed` line that holds a usable rule | the line in lesson form |
| `keep` | Anything else, including recent lessons that have not recurred yet | nothing |

## Text rules

- Merged line: `<newest date of the group> — <shared context, or the broader one> — <the
  stricter wording, one sentence>`. It replaces the line with the newest date; the others are
  deleted.
- Conventions line: the rule alone, imperative, no date, no context, no "because". If it needs
  a "because", it is a decision. Pick the section from the headings already in
  `conventions.md` (`Code style`, `Patterns`, `Naming`, `Testing rules`, `Git and PR rules`,
  `Never`); never add a heading.
- Decision: title in kebab case from the rule; Context = the situation the lesson came from;
  Decision = the rule as one paragraph; Consequences = what it costs. At most 40 lines.
- Malformed line with no usable rule: `delete`.
- Script `duplicates` are candidates, not verdicts. A pair that shares words but not meaning
  stays two lessons.

## Over the cap after the proposal

The proposal does not delete lessons just to fit. If the projected count is still over, say
so and list the five oldest `keep` rows with their age, so the user can choose to delete some
in the adjust round.
