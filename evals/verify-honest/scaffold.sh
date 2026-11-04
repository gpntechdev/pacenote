#!/bin/bash
# item-rename is implemented and reviewed; the matrix names a test for AC4 that was never
# written. runtime_verify is off so verify asks nothing about a running app.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
ws_config flow.runtime_verify=off
ws_commit "chore: no runtime verification"
ws_feature item-rename full verify G1 G2 G3 G4
"$PLUGIN/scripts/state" set --file "$W/spec/item-rename/state.yml" tasks.T1=done tasks.T2=done review.round=1 >/dev/null
ws_copy
ws_commit "feat(items): rename an item"
