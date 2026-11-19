#!/bin/bash
# A full feature at tasks with an approved spec (AC1-AC5) and design.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
ws_feature item-admin full tasks G1 G2
ws_copy
ws_commit "spec(item-admin): spec and design"
