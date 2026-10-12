---
name: close
description: >
  Invoke whenever the user asks to close, finish, wrap up or clean up a delivered feature
  whose pull request is settled, or runs `/specd:close [feature]`; the last step before the
  merge. It applies the retention policy: distill (the docs step must have written the
  feature record; then delete the spec folder), clean (delete the spec folder) or keep
  (mark closed and leave it), commits and pushes so the open PR carries the result; in a
  wrapper it also removes the feature worktree and merges the wrapper branch into the
  wrapper's default branch. Not for closing the PR itself; merging the code is yours, after
  this push.
---

# Skill: close

Ends the feature's working set. The durable knowledge was written by `docs` before the PR;
the spec folder is ephemeral and leaves here, once nobody needs it: run it when the PR has
no open comments left, then merge. Git history is the archive. The default policy comes
from the tier and `flow.retention`; the user confirms it per feature. In a wrapper the
feature also leaves its branch: the wrapper has no PR, so this step merges it.

## Gate

`state check --step close`: `step` is `close` (delivered) or `closed` (kept earlier; close
again to clean it). A merged PR is refused: the folder is already on the default branch.

## Inputs

- `resolve-paths`, `detect-repo` (code remote host; wrapper default branch and remote),
  `state find`, `state check`, `scripts/worktree`
  ([`../_shared/paths.md`](../_shared/paths.md): the opening sequence, which repo holds what).
- `<spec_root>/<feature>/state.yml` (`retention`, `tier`, `pr`, `branch`, `worktree`).
- `<docs_root>/features/<feature>.md` (must exist for `distill`).
- `<workspace_root>/specd.yml`: `flow.retention`, `git.authority`, `git.pr_host`.
- [`../_shared/state-yml.md`](../_shared/state-yml.md),
  [`../deliver/references/git.md`](../deliver/references/git.md) ("Wrapper": the push rule).

## Outputs

- distill or clean: spec folder removed. keep: `step: closed`.
- One commit `docs(<feature>): close (<policy>)` in the repo holding the spec folder, pushed
  when authority ≥ `push` and the branch is on the remote.
- Wrapper: the worktree removed when there was one; the wrapper branch merged into the
  wrapper's default branch and deleted locally.

## Protocol

1. **Resolve** per `paths.md`, `state check --step close`. When `pr` is set and the host
   CLI exists (`gh pr view <url> --json state`, `glab mr view <url>`, from `<code_root>`):
   state `MERGED` → refuse in one line (the spec folder is on `<default>`; remove it on a
   branch by hand) and end with the handoff. CLI missing: continue. Policy = `retention`
   in `state.yml`, else `clean` for trivial and quick, `flow.retention` for full. Confirm in
   one question: distill / clean / keep, with the default first.
2. **distill.** `<docs_root>/features/<feature>.md` missing: stop, handoff `Next:
   /specd:docs <feature>` (the record is written there, then close again). Present:
   `git -C <workspace_root> rm -r <spec_root>/<feature>`.
3. **clean.** `git -C <workspace_root> rm -r <spec_root>/<feature>`.
4. **keep.** `state set step=closed retention=keep worktree=`. The folder stays; `status`
   warns after `flow.keep_days`.
5. **Commit** `docs(<feature>): close (<policy>)` with `git -C <workspace_root>`; push when
   authority ≥ `push` and `branch` is set: the same push as `deliver` in embedded mode, the
   `git.md` "Wrapper" rule when the wrapper is a second repo.
6. **Wrapper branch** (only when `<workspace_root>` is another repo than `<code_root>`).
   `worktree` set: the session must not sit inside the worktree it removes (`resolve-paths`
   without `--feature` reports a `worktree`): say `run /specd:close <feature> from
   <wrapper_root>` and stop before anything is removed. Then
   `"${CLAUDE_PLUGIN_ROOT}/scripts/worktree" remove --feature <feature> --from
   <wrapper_root>`; a refusal (dirty code tree) is printed as is and the run stops here,
   everything above is already committed. Then, in `<wrapper_root>`, which must be on
   its default branch with a clean tree (else say which branch or files block and stop):
   `git merge --no-ff <branch>` with the message `docs(<feature>): merge <branch>`, then
   `git branch -d <branch>`; push the default branch under the `git.md` "Wrapper" rule.
   Without a worktree the wrapper is checked out on `<branch>`: `git checkout <default>`
   first (clean tree required), then the same merge. A merge conflict (two features
   touching `features/README.md`) stops with the files named; resolving or aborting is the
   user's. The code repo is never merged here.
7. **Handoff** per [`../_shared/handoff.md`](../_shared/handoff.md). `Produced`: the removal
   or the closed marker; the merge, when one ran. `Review`: none. `Next: /specd:status`;
   say that merging the PR (from `pr`, if any) is the user's call: in embedded mode the PR
   now carries the removal; in a wrapper the spec history is on the wrapper's default
   branch and the PR is unchanged.

## Anti-patterns

- Writing the feature record or decisions here; that is `docs`, before the PR.
- Closing while PR comments are still open; `feedback` needs the folder (and the worktree).
- Keeping "just in case"; keep is a choice with a reason, and `status` will nag.
- Renaming or rebasing the branch; the removal is one more commit on it.
- Removing a worktree with `--force`, or merging the wrapper branch over a conflict; both
  are the user's hand.
- Merging, rebasing or deleting anything in the code repo.
