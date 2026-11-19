#!/bin/bash
# The seeded malicious skill from tests/fixtures (M6) sits in candidates/ as a local candidate.
. "$(dirname "$0")/../_lib/workspace.sh"
ws_repo
ws_init
mkdir -p candidates
cp -R "$PLUGIN/tests/fixtures/malicious-skill" candidates/formatter
ws_commit "chore: a candidate skill"
