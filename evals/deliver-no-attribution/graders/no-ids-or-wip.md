---
type: regex
target: { source: file, path: .pacenote/spec/item-rename/change-summary.md }
pattern: '\b(T\d+|AC\d+|F\d+)\b|WIP:'
match: not_contains
---
