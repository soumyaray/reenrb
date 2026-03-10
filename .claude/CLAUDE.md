# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Reenrb is a Ruby gem for mass renaming/deleting files through an interactive editor. It provides both a CLI (`reen`) and a programmatic API. Version 0.4.0, requires Ruby >= 3.0.

## Common Commands

```bash
bundle exec rake              # Run tests + rubocop (default task)
bundle exec rake spec         # Run all tests (minitest)
bundle exec rake rubocop      # Lint only
bundle exec rake respec       # Auto-rerun tests on file changes

# Run a single test file
bundle exec ruby -Ispec:lib spec/spec_changes.rb

# Test fixtures
bundle exec rake example:recreate  # Extract example.zip for tests
bundle exec rake example:remove    # Clean up extracted fixtures
```

## Architecture

**Flow:** `ReenCLI (bin/reen)` → `Reenrb::Reen` → `ChangesFile` (temp file + editor) → `Changes` → `Change` → `Action`

- **`Reenrb::Reen`** (`lib/reenrb/reen.rb`) — Main orchestrator. Two-phase workflow: `request()` analyzes changes, `execute()` applies them. Constructor takes `editor:` (defaults to $VISUAL/$EDITOR) and `options:`.
- **`Reenrb::Changes`** (`lib/reenrb/changes.rb`) — Collection of `Change` objects with filtering (`rename_requested`, `delete_requested`, `accepted`, `rejected`, `executed`, `failed`) and `execute_all`.
- **`Reenrb::Change`** (`lib/reenrb/change.rb`) — Parses a single original→requested pair. Prefix `-` = delete, `--` = force delete. Maps change type to action handler via `ACTION_HANDLER` constant. Auto-rejects non-empty directory deletion (unless force).
- **`Reenrb::ChangesFile`** (`lib/reenrb/changes_file.rb`) — Manages Tempfile for editor interaction, writes instructions header, parses edited result.
- **Actions** (`lib/reenrb/actions/`) — Strategy pattern: `Rename`, `Delete`, `ForceDelete`, `DoNothing`. Each has `new(old, new)` and `call()` returning nil (success) or error string.

## Test Setup

- **Framework:** Minitest with describe/it blocks, minitest-rg for formatting, SimpleCov for coverage
- **Fixtures:** `spec/fixtures/example.zip` extracted to `spec/fixtures/example/` via `FixtureHelper` before tests
- **Test files:** `spec/spec_*.rb` pattern (spec_reenrb, spec_changes, spec_requests)

## Style

- RuboCop enforced: double quotes, 120 char line length, NewCops enabled
- Target Ruby version: 3.0
