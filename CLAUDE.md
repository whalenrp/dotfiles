  # Global Claude Code Configuration

  ## General Guidelines
  - Use clear and descriptive variable names.
  - Structure diffs such that they can be merged independently, unless the intent of a change wouldn't be clear without the context of other changes.
  - Use subagents that pass back information about their work to the main agent for exploratory tasks.
  - When writing markdown files, put them in /tmp so that they don't clutter up the branch that I'm working on

  ## Comment Style
  - Keep comments short and succinct - focus on the "why" not the "what"
  - DO NOT include verbose examples or API usage demonstrations in comments
  - Highlight important gotchas or non-obvious behavior
  - Avoid redundant comments that just restate the code
  - Good: `// Returns nil if context was already cancelled`
  - Bad: `// GetContext returns the context value. Example: ctx := GetContext(parent)`

  ## Testing and Investigation Workflow

  ### Ask First
  When creating tests or benchmarks, clarify upfront:
  - "Is this for the final commit, or exploratory/temporary?"
  - This helps determine naming, location, and level of polish

  ### Production Tests (Going into commits)
  - Add only minimum tests needed to meet coverage requirements
  - Avoid tests that create maintenance overhead without significant value
  - Keep focused and maintainable
  - Use standard naming: `foo_test.go`, `BenchmarkFoo`

  ### Exploratory Tests and Benchmarks (Temporary investigation)
  - **Prefix with `scratch_`** to indicate temporary status: `scratch_context_chain_bench_test.go`
  - Create comprehensive benchmarks to answer specific performance questions
  - These will be deleted before commit - the prefix makes cleanup easy
  - Can be verbose and experimental - optimization for insight, not maintenance
  - Put in project root or appropriate package, NOT in /tmp (they need to compile)

  ### Benchmark Organization
  - Combine related benchmarks in single files when practical
  - Use clear names explaining what's measured: `BenchmarkOldVsNew_DeepNesting`
  - Include brief comments on complex setups, but keep them concise

  ## Implementation Philosophy
  - Before implementing solutions, confirm the scope matches user intent - default to minimal, focused changes rather than expansive cross-cutting modifications.
  - When user asks for a simple solution, implement the minimal version first. Avoid over-engineering with separate configs, multiple views, or extensive infrastructure when a single parameter would suffice.
  - Prefer additive-only modifications to existing config files to minimize review risk and avoid accidental deletions.

  ## Notification Protocol
  Always notify user with terminal bell in these situations:
  - When needing user input: `echo -e '\a' && read -p "❓ Input needed: "`
  - After completing long tasks: `echo -e '\a' && echo "✅ Task completed"`
  - When commands fail: `echo -e '\a\a\a' && echo "❌ Command failed"`

  ## Phabricator Diff Workflow
  - NEVER create or update diffs (`arc diff`) unless explicitly asked by the user
  - When asked to "create a diff", only run `arc diff --create` once
  - Do NOT automatically update diffs after making additional changes - wait for explicit instruction
  - If the user makes changes after a diff is created, ask if they want to update the diff rather than doing it automatically

  ## Go Guidelines

  - Our styleguide is here: https://github.com/uber-go/guide/blob/master/style.md

  ## Subagents
  - Subagents should pass back to the main agent a summary of their work and any relevant data or results. This allows the main agent to keep track of progress and make informed decisions about next steps.

