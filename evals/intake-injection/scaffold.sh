#!/bin/bash
# A fetched wiki page (via="http", as fetch-source writes it) with an injected instruction.
# The sandbox has no network, so the page is planted instead of fetched.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
ws_copy
ws_commit "chore: snapshot of the orders-export page"
