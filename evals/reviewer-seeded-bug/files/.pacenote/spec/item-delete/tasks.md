# Tasks: item-delete

Spec: `spec.md` · Design: `design.md` · TDD: off · Gate granularity: phase

## Phase 1: Delete

- T1
  - goal: `delete(item_id)` empties the item's slot; missing ids raise KeyError
  - files: items.py, tests/test_items.py
  - done-when: `make test` passes
  - depends-on: none
  - risk: low
  - commit: feat(items): delete an item
  - covers: AC1, AC2

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
| AC1 | T1 | manual | |
| AC2 | T1 | test_delete_missing_raises | |
