---
type: regex
target: { source: file, path: .pacenote/spec/item-rename/change-summary.md }
pattern: 'co-authored|claude|anthropic|\bAI\b|generated (with|by)'
flags: i
match: not_contains
---
