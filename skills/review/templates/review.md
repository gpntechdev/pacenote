<!-- Written by /pacenote:review to <spec_root>/<feature>/review.md, one "## Round n" per run;
     /pacenote:feedback appends "## PR round n" sections (PR comments as C<k>, resolution fix /
     reply / skip). Read by deliver and docs. Findings keep their ids across rounds (F1..
     continue; specialist findings use their lens prefix SEC, PERF, A11Y, TEST and the lens as
     Ref). Each resolution is fix (-> task id), accept (reason) or dispute (reason). -->
# Review: {{feature}}

Spec: `spec.md` · Tasks: `tasks.md`

## Round 1

Date: {{date}} · Diff: {{files changed}} files · Verdict: {{ship | fix first}}
Specialists: {{lens (verdict), … | none}}

### Acceptance criteria

| AC | Status | Note |
|---|---|---|
| AC1 | covered | |

### Findings

| Id | Severity | Where | Ref | Finding | Fix | Resolution |
|---|---|---|---|---|---|---|
| F1 | major | `path:line` | AC2 | | | fix -> T9 |
| SEC1 | blocker | `path:line` | security | | | fix -> T10 |
