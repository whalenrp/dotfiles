  # Global Claude Code Configuration

  ## Notification Protocol
  Always notify user with terminal bell in these situations:
  - When needing user input: `echo -e '\a' && read -p "❓ Input needed: "`
  - After completing long tasks: `echo -e '\a' && echo "✅ Task completed"`
  - When commands fail: `echo -e '\a\a\a' && echo "❌ Command failed"`
