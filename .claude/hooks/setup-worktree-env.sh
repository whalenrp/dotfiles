#!/bin/bash
# PostToolUse hook: write .claude/settings.json into a new worktree so that
# GOPATH/WORKSPACE_ROOT/PYTHONPATH point at the worktree root, not the main repo.
# Uses `direnv exec` to evaluate .envrc and captures only the delta vs current env.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
[ "$TOOL_NAME" = "Bash" ] || exit 0

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
echo "$COMMAND" | grep -qE 'git[[:space:]].*worktree[[:space:]].*add' || exit 0

# Extract ~/worktrees/* or /home/*/worktrees/* path from the command.
WORKTREE_PATH=$(echo "$COMMAND" | grep -oE '(~/worktrees|/home/[^[:space:]]+/worktrees)/[^[:space:];|&"'"'"']+' | head -1)
WORKTREE_PATH="${WORKTREE_PATH/#\~/$HOME}"

[ -n "$WORKTREE_PATH" ] || exit 0
[ -d "$WORKTREE_PATH" ] || exit 0

SETTINGS_FILE="$WORKTREE_PATH/.claude/settings.json"
[ -f "$SETTINGS_FILE" ] && exit 0  # don't clobber an existing config

# Trust the worktree's .envrc so direnv exec can evaluate it.
direnv allow "$WORKTREE_PATH" 2>/dev/null

# Derive env vars by diffing current env against what direnv would set in the worktree.
ENV_JSON=$(python3 - "$WORKTREE_PATH" <<'PYEOF'
import json, subprocess, sys

wt = sys.argv[1]

def parse_env(lines):
    env = {}
    for line in lines:
        if '=' in line:
            k, v = line.split('=', 1)
            env[k] = v
    return env

current = parse_env(subprocess.run(['env'], capture_output=True, text=True).stdout.splitlines())
with_direnv = parse_env(subprocess.run(['direnv', 'exec', wt, 'env'], capture_output=True, text=True).stdout.splitlines())

# Vars that direnv adds or changes, minus its own internals and PATH (PATH is
# already correct since the main repo's bin is on it and the content is identical).
exclude = {'DIRENV_DIR', 'DIRENV_FILE', 'DIRENV_WATCHES', 'DIRENV_DIFF', 'DIRENV_IN_ENVRC', '_', 'PATH', 'SHLVL', 'PWD', 'OLDPWD'}
delta = {k: v for k, v in with_direnv.items() if current.get(k) != v and k not in exclude}

print(json.dumps(delta, indent=2))
PYEOF
)

mkdir -p "$WORKTREE_PATH/.claude"
printf '{\n  "env": %s\n}\n' "$ENV_JSON" > "$SETTINGS_FILE"
echo "Configured worktree env: $WORKTREE_PATH"
