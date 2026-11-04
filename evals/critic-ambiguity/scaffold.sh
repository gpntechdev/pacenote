#!/bin/bash
# A spec with two vague terms ("fast", "recent") and a payment call with no failure path.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
ws_feature order-history full specify
ws_copy
ws_commit "spec(order-history): draft spec"
