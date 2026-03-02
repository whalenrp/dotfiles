#!/bin/bash

# Read JSON input
input=$(cat)

# Git branch (skip locks for speed)
branch=$(git -c core.fileMode=false -c advice.detachedHead=false -c gc.auto=0 branch --show-current 2>/dev/null || echo "no-git")

# Git worktree info
worktree_info=""
if [ "$branch" != "no-git" ]; then
  # Check if in a worktree
  is_worktree=$(git rev-parse --is-inside-work-tree 2>/dev/null)
  if [ "$is_worktree" = "true" ]; then
    git_dir=$(git rev-parse --git-dir 2>/dev/null)
    if [[ "$git_dir" == *".git/worktrees"* ]]; then
      worktree_name=$(basename "$git_dir")
      worktree_info=" [wt:$worktree_name]"
    fi
  fi
fi

# Context window usage
ctx_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_display=""
if [ -n "$ctx_pct" ]; then
  ctx_display=$(printf " ctx:%.0f%%" "$ctx_pct")
fi

# Output
printf "%s%s%s" "$branch" "$worktree_info" "$ctx_display"
