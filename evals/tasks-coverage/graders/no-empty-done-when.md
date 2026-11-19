---
type: regex
target: { source: file, path: .pacenote/spec/item-admin/tasks.md }
pattern: 'done-when:[ \t]*(\n|$)'
match: not_contains
---
