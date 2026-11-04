#!/bin/bash
# A fresh workspace with no feature yet; start triages the request in the prompt.
. "$(dirname "$0")/../../_lib/workspace.sh"
ws_repo
ws_init
[ -d "$CASE/files" ] && ws_copy && ws_commit "chore: fixture files"
exit 0
