<!-- Written by /pacenote:tasks to <spec_root>/<feature>/tasks/T<n>.md for a task whose body
     would pass ~100 lines in tasks.md; read by implement for this task only, and by review
     when the task fixes a finding. Same fields as an inline task block; the index line in
     tasks.md must agree with goal, risk and covers. -->
# T{{n}}: {{goal in one line}}

Phase: {{phase name}} · Risk: {{low|high}} · Layer: {{key of pacenote.yml layers, or none}} · Covers: {{AC ids}} · Depends on: {{ids or none}}

## Goal

<!-- One paragraph: what exists when this task is done, and the design headings or
     decisions it follows. -->

## Files

<!-- One path per line, with "new" or "edit". -->

## Done-when

<!-- A command that exits 0, or an observable; the exact command when there is one. -->

## Commit

`{{type}}({{scope}}): {{summary}}`

## Tests

<!-- TDD only. One case per behaviour: name — what it asserts. Error paths get their own. -->
