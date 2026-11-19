#!/bin/bash
# The items feature sits at specify with G1 unapproved; tasks must refuse.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
ws_feature items full specify
ws_copy
ws_commit "spec(items): draft spec"
