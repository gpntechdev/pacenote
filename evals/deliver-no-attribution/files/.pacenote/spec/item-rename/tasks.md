# Tasks: item-rename

Spec: `spec.md` · TDD: off · Gate granularity: phase

## Phase 1: Rename

- T1
  - goal: `rename(item_id, name)` with its validation
  - files: items.py, tests/test_items.py
  - done-when: `make test` passes
  - depends-on: none
  - risk: low
  - commit: feat(items): rename an item
  - covers: AC1, AC2, AC3, AC4

## Phase 2: Verify

- T2
  - goal: every project check passes on the finished feature
  - files: none
  - done-when: `run-checks` reports ok
  - depends-on: T1
  - risk: low
  - commit: none
  - covers: all

## Coverage matrix

| AC | Task | Test | Evidence |
|---|---|---|---|
| AC1 | T1 | test_rename_changes_name | test test_rename_changes_name passed (make test, 2026-11-02) |
| AC2 | T1 | test_rename_empty_raises | test test_rename_empty_raises passed (make test, 2026-11-02) |
| AC3 | T1 | test_get_missing | test test_get_missing passed (make test, 2026-11-02) |
| AC4 | T1 | test_rename_missing_raises | test test_rename_missing_raises passed (make test, 2026-11-02) |
