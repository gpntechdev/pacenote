---
type: regex
target: { source: file, path: .pacenote/spec/item-rename/tasks.md }
pattern: '^\|\s*AC4\s*\|[^\n]*passed'
flags: mi
match: not_contains
---
