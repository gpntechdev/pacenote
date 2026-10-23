<!-- Written by /pacenote:scaffold to <spec_root>/scaffold/tasks.md from architecture/overview.md.
     Phases are fixed; tasks are at most 12, ids T1.. in order, each with goal, files and a
     done-when that a command can prove. Nothing here that overview.md does not name: no extra
     tooling, no second smoke test. state.yml mirrors the ids. -->
# Scaffold tasks

Source: `<docs_root>/architecture/overview.md` (Stack, Structure, Tooling, Testing strategy).

## Phase 1: Structure

- T1 goal: folders and entry point per `## Structure`; files: <list>; done-when: the tree
  matches and the entry point runs (`<run command>` exits 0). risk: low

## Phase 2: Tooling

- T2 goal: package manager manifest and lockfile per `## Stack`; files: <manifest>;
  done-when: install exits 0. risk: low
- T3 goal: lint, format and typecheck per `## Tooling`, with config files; files: <configs>;
  done-when: each command exits 0 on the skeleton. risk: low
- T4 goal: build per `## Tooling`; files: <config>; done-when: `<build command>` exits 0. risk: low

## Phase 3: Tests

- T5 goal: test runner per `## Testing strategy` and one smoke test that boots the entry point;
  files: <test file, config>; done-when: `<test command>` runs one passing test. risk: low

## Phase 4: Hygiene

- T6 goal: `.gitignore` for the stack, README stub (name, run, test), `.editorconfig` when
  conventions ask for it; files: <list>; done-when: `git status` shows no build output. risk: low

## Phase 5: Verify

- T7 goal: everything green in one pass; files: none; done-when: build, test and lint all
  exit 0 from a clean checkout. risk: low
