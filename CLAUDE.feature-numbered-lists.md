# Numbered List Prefixes for Editor

> **IMPORTANT**: This plan must be kept up-to-date at all times. Assume context can be cleared at any time — this file is the single source of truth for the current state of this work. Update this plan before and after task and subtask implementations.

## Branch

`feature-numbered-lists`

## Goal

Add numbered prefixes (e.g., `[01]`, `[002]`) to the file list shown in the editor so users can freely reorder entries without losing track of which original file each line corresponds to. Matching changes back to originals uses the number, not line position. Also fix the dash-operator ambiguity by requiring a space after `-`/`--` to distinguish delete operations from literal filenames starting with dashes. Introduce `PathEntry` and `PathEntryList` domain objects to replace raw path strings — `PathEntry` wraps a file path and answers filesystem queries, `PathEntryList` is a collection that owns numbered serialization for the editor.

## Strategy: Vertical Slice

1. **Refactor** — Introduce `PathEntry`/`PathEntryList` domain objects, migrate existing code (all tests pass)
2. **Fix** — Require space after `-`/`--` for delete operators (dash ambiguity fix)
3. **Feature** — Add numbered prefixes and number-based matching
4. **Verify** — Manual test with real editor confirms behavior

## Current State

- [x] Plan created
- [ ] Slice 0: PathEntry/PathEntryList refactor
- [ ] Slice 1: Dash-operator ambiguity fix
- [ ] Slice 2: Numbered prefixes
- [ ] Slice 3: Number-based matching
- [ ] Slice 4: Documentation
- [ ] Slice 5: Verification

## Key Findings

- `Change` currently owns filesystem queries (`request_dir?`, `request_file?`, `request_empty_dir?`, `request_full_dir?`) by checking `@original` path directly. These should move to `PathEntry`.
- `Change` will hold an `PathEntry` instead of a raw `@original` string. `Change#original` delegates to `PathEntry#path`.
- `PathEntryList` wraps an array of `PathEntry` objects. Constructed from `Dir.glob` results (array of strings). Owns numbered serialization (writing `[NN] path` lines) and parsing (stripping prefixes, returning number-keyed entries).
- `ChangesFile#initialize` currently writes `requested_list.join("\n")` — will instead take an `PathEntryList` and call its serialization.
- `ChangesFile#allow_changes` reads back lines, strips comments/blanks — will delegate prefix parsing to `PathEntryList`.
- `Reen#request` does positional matching via `original_list.zip(changed_list)` — changes to number-based matching via `PathEntryList`.
- `Reen#request` raises if list sizes differ (line deletion guard) — still valid with numbered approach.
- `Change#extract_request` parses operator prefixes (`-`, `--`) greedily, which means renaming to `-` or `--` is impossible. Fix: require a space after `-`/`--` to trigger delete.
- Tests manipulate `file.list` directly (mock editor) — the list exposed to the block will include number prefixes so test blocks simulate what a real user sees/edits.
- Number width is auto-sized: `format("%0#{width}d")` where `width = list.size.to_s.length`.

## Questions

- ~~Should `Change` know about number prefixes?~~ No — `ChangesFile` handles writing and stripping prefixes. `Change` and `Reen` see clean filenames. `Reen#compare_lists` changes from positional zip to number-keyed matching.
- ~~Should dashes go before or after number prefixes?~~ After. Dashes are operators on the filename, numbers are stable anchors: `[01] - file` = delete, `[01] -file` = rename to `-file`. Require space after `-`/`--` to distinguish.
- [ ] Should reordering be reflected in the output summary? (Probably not needed for v1.)

## Scope

**In scope**:

- `PathEntry` (`lib/reenrb/path_entry.rb`): wraps a file path, provides `file?`, `dir?`, `empty_dir?`, `full_dir?`, `path`
- `PathEntryList` (`lib/reenrb/path_entry_list.rb`): collection of `PathEntry`, constructed from string array, owns numbered serialization/parsing
- `Change`: refactor to hold `PathEntry` instead of raw string, delegate filesystem queries to `PathEntry`
- `Change#extract_request`: require space after `-`/`--` for delete operators (fixes dash-name ambiguity)
- `ChangesFile`: use `PathEntryList` for writing/reading, numbered prefixes, updated instructions
- `Reen`: accept `PathEntryList` (or build one from string array), number-based matching
- Tests for: `PathEntry`, `PathEntryList`, dash-space fix, prefix formatting/stripping, reordered matching

**Out of scope**:

- Reporting reorder information to the user
- Any CLI flag to disable numbering
- `Changes` refactor (stays as-is, wraps array of `Change`)

## Tasks

> **Strict TDD cycle**: For each slice — (1) run full suite to confirm green baseline, (2) write failing tests (RED), (3) run tests to confirm they fail, (4) implement (GREEN), (5) run full suite to confirm all pass.

### Slice 0: Introduce PathEntry and PathEntryList domain objects (refactor)

- [ ] 0.0 Run full suite — confirm green baseline
- [ ] 0.1 RED — Write failing tests in `spec/spec_path_entry.rb`:
  - [ ] 0.1a `PathEntry` wraps a path and delegates `file?`, `dir?`, `empty_dir?`, `full_dir?`
  - [ ] 0.1b `PathEntryList` constructs from array of strings, iterates as `PathEntry` objects
  - [ ] 0.1c `PathEntryList#paths` returns array of path strings
- [ ] 0.2 Run new tests — confirm RED (failures)
- [ ] 0.3 GREEN — Implement `PathEntry` (`lib/reenrb/path_entry.rb`)
- [ ] 0.4 GREEN — Implement `PathEntryList` (`lib/reenrb/path_entry_list.rb`)
- [ ] 0.5 Run new tests — confirm GREEN (pass)
- [ ] 0.6 Refactor `Change` to hold `PathEntry`, delegate filesystem queries
- [ ] 0.7 Refactor `Reen` and `ChangesFile` to accept/use `PathEntryList`
- [ ] 0.8 Run full suite — confirm all tests pass (update as needed)

### Slice 1: Fix dash-operator ambiguity in Change

- [ ] 1.0 Run full suite — confirm green baseline
- [ ] 1.1 RED — Write failing tests in `spec/spec_change.rb`:
  - [ ] 1.1a `- filename` (with space) triggers delete
  - [ ] 1.1b `-filename` (no space) triggers rename to `-filename`
  - [ ] 1.1c `-- filename` (with space) triggers force delete
  - [ ] 1.1d `--filename` (no space) triggers rename to `--filename`
- [ ] 1.2 Run new tests — confirm RED (1.1b and 1.1d fail)
- [ ] 1.3 GREEN — Update `Change#extract_request` regex to require space after `-`/`--`
- [ ] 1.4 Run full suite — confirm GREEN (update any tests that relied on no-space dash)

### Slice 2: Numbered prefixes in PathEntryList and ChangesFile

- [ ] 2.0 Run full suite — confirm green baseline
- [ ] 2.1 RED — Write failing tests:
  - [ ] 2.1a `PathEntryList#to_numbered` serializes as `[NN] path` lines (auto-sized width)
  - [ ] 2.1b `PathEntryList.from_numbered` parses `[NN] path` lines back to number-keyed entries
  - [ ] 2.1c `ChangesFile` instructions header mentions not changing numbers and allowing reorder
- [ ] 2.2 Run new tests — confirm RED (failures)
- [ ] 2.3 GREEN — Implement `PathEntryList#to_numbered` and `PathEntryList.from_numbered`
- [ ] 2.4 GREEN — Update `ChangesFile` to use numbered serialization
- [ ] 2.5 GREEN — Update `INSTRUCTIONS` constant with reorder/number guidance
- [ ] 2.6 Run full suite — confirm all tests pass

### Slice 3: Number-based matching in Reen

- [ ] 3.0 Run full suite — confirm green baseline
- [ ] 3.1 RED — Write failing tests:
  - [ ] 3.1a `Reen#request` correctly matches reordered entries to originals by number
  - [ ] 3.1b `Reen#request` still raises error when lines are removed
- [ ] 3.2 Run new tests — confirm RED (3.1a fails)
- [ ] 3.3 GREEN — Change `Reen#compare_lists` to match by number key instead of positional zip
- [ ] 3.4 GREEN — Update existing tests that manipulate `file.list` to account for numbered prefixes
- [ ] 3.5 Run full suite — confirm all tests pass

### Slice 4: Documentation

- [ ] 4.1 Update README.md: document numbered prefixes, dash-space syntax, reordering support
- [ ] 4.2 Update CLI help text in `bin/reen` if needed
- [ ] 4.3 Verify `ChangesFile::INSTRUCTIONS` final wording (from Slice 2.5)

### Slice 5: Verification

- [ ] 5.1 Run full suite (`bundle exec rake`) — all green
- [ ] 5.2 Manual verification with real editor

## Completed

(none yet)

---

Last updated: 2026-03-10
