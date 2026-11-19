# Shared scaffold for pacenote eval cases. Not a case: sourced by each case's scaffold.sh,
# which runs in the run's empty workspace before Claude starts:
#
#   . "$(dirname "$0")/../_lib/workspace.sh"     # nested cases: ../../_lib/workspace.sh
#
# Every pacenote file is made by the plugin's own scripts, so fixtures follow schema changes.
set -euo pipefail

LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN="$(cd "$LIB/../.." && pwd)"
CASE="$(cd "$(dirname "$0")" && pwd)"
W=.pacenote

# A git repo on main with the fixture app and one commit.
ws_repo() {
  git init -q -b main .
  git config user.name "Eval User"
  git config user.email "eval@example.invalid"
  cp -R "$LIB/app/." .
  ws_commit "chore: add the app"
}

# An embedded workspace with the fixture docs and the app's test command, committed.
ws_init() {
  "$PLUGIN/scripts/init-workspace" --root . >/dev/null
  cp "$LIB/docs/"*.md "$W/docs/"
  ws_config project=items commands.test="make test"
  ws_commit "chore: initialise pacenote workspace"
}

# Patch pacenote.yml: ws_config key=value ...
ws_config() {
  "$PLUGIN/scripts/config-set" --file "$W/pacenote.yml" "$@" >/dev/null
}

# A feature on its own branch at a step, with the named gates stamped:
# ws_feature <name> <tier> <step> [G1 G2 ...]
ws_feature() {
  local name="$1" tier="$2" step="$3"
  shift 3
  local file="$W/spec/$name/state.yml"
  git checkout -q -b "feat/$name"
  "$PLUGIN/scripts/state" init --file "$file" --feature "$name" --tier "$tier" \
    --step "$step" --branch "feat/$name" >/dev/null
  local gate
  for gate in "$@"; do
    "$PLUGIN/scripts/state" set --file "$file" "gates.$gate=now" >/dev/null
  done
}

# Copy a folder of the case (default: files/) over the workspace.
ws_copy() {
  cp -R "$CASE/${1:-files}/." .
}

ws_commit() {
  git add -A
  git commit -q -m "$1"
}
