#!/bin/bash
# item-rename is built, reviewed, verified and documented, with WIP task commits on its
# branch; authority is commit, so deliver drafts the summary and then asks about the squash.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
ws_config git.authority=commit
ws_commit "chore: local commits only"
ws_feature item-rename full deliver G1 G2 G3 G4
"$PLUGIN/scripts/state" set --file "$W/spec/item-rename/state.yml" tasks.T1=done tasks.T2=done \
  review.round=1 runtime_verify=off >/dev/null
cp "$CASE/files/.pacenote/spec/item-rename/spec.md" "$W/spec/item-rename/"
ws_commit "spec(item-rename): spec"
cp "$CASE/files/items.py" .
ws_commit "WIP: T1 rename an item"
cp "$CASE/files/tests/test_items.py" tests/
ws_commit "WIP: T1 fix test"
ws_copy
ws_commit "spec(item-rename): review, verify and docs"
