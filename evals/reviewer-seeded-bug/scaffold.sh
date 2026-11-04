#!/bin/bash
# item-delete is implemented on its branch with an off-by-one in delete; the feature is at
# review. Specialists are off so review records its findings before the first question.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
ws_config flow.specialists=off
ws_commit "chore: no specialist passes"
ws_feature item-delete full review G1 G2 G3 G4
"$PLUGIN/scripts/state" set --file "$W/spec/item-delete/state.yml" tasks.T1=done tasks.T2=done >/dev/null
ws_copy
ws_commit "feat(items): delete an item"
