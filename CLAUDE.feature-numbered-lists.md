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
- [x] Slice 0: PathEntry/PathEntryList refactor
- [x] Slice 1: Dash-operator ambiguity fix
- [x] Slice 2: Numbered prefixes
- [x] Slice 3: Number-based matching
- [x] Slice 4: Documentation
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
- File/folder creation via unnumbered lines (touch/mkdir) — future feature, separate branch

## Tasks

> **Strict TDD cycle**: For each slice — (1) run full suite to confirm green baseline, (2) write failing tests (RED), (3) run tests to confirm they fail, (4) implement (GREEN), (5) run full suite to confirm all pass. **Check off each step immediately after completing it.**

### Slice 0: Introduce PathEntry and PathEntryList domain objects (refactor)

- [x] 0.0 Run full suite — confirm green baseline (11 tests, 0 failures)
- [x] 0.1 RED — Write failing tests in `spec/spec_path_entry.rb`:
  - [x] 0.1a `PathEntry` wraps a path and delegates `file?`, `dir?`, `empty_dir?`, `full_dir?`
  - [x] 0.1b `PathEntryList` constructs from array of strings, iterates as `PathEntry` objects
  - [x] 0.1c `PathEntryList#paths` returns array of path strings
- [x] 0.2 Run new tests — confirm RED (6 errors, uninitialized constant)
- [x] 0.3 GREEN — Implement `PathEntry` (`lib/reenrb/path_entry.rb`)
- [x] 0.4 GREEN — Implement `PathEntryList` (`lib/reenrb/path_entry_list.rb`)
- [x] 0.5 Run new tests — confirm GREEN (6 runs, 27 assertions, 0 failures)
- [x] 0.6 Refactor `Change` to hold `PathEntry`, delegate filesystem queries
- [x] 0.7 Refactor `Reen` and `ChangesFile` to accept/use `PathEntryList`
- [x] 0.8 Run full suite — confirm all tests pass (17 runs, 58 assertions, 0 failures)

### Slice 1: Fix dash-operator ambiguity in Change

- [x] 1.0 Run full suite — confirm green baseline (17 runs, 0 failures)
- [x] 1.1 RED — Write failing tests in `spec/spec_change.rb`:
  - [x] 1.1a `- filename` (with space) triggers delete
  - [x] 1.1b `-filename` (no space) triggers rename to `-filename`
  - [x] 1.1c `-- filename` (with space) triggers force delete
  - [x] 1.1d `--filename` (no space) triggers rename to `--filename`
- [x] 1.2 Run new tests — confirm RED (1.1b and 1.1d fail as expected)
- [x] 1.3 GREEN — Updated `Change#extract_request` regex: `^(--|-)·(?<name>.*)` with fallback `^()(?<name>.*)`
- [x] 1.4 Run full suite — confirm GREEN (21 runs, 64 assertions, 0 failures)

### Slice 2: Numbered prefixes in PathEntryList and ChangesFile

- [x] 2.0 Run full suite — confirm green baseline (21 runs, 0 failures)
- [x] 2.1 RED — Write failing tests:
  - [x] 2.1a `PathEntryList#to_numbered` serializes as `[NN] path` lines (auto-sized width)
  - [x] 2.1b `PathEntryList.from_numbered` parses `[NN] path` lines back to number-keyed entries
  - [x] 2.1c (deferred to Slice 4 — documentation)
- [x] 2.2 Run new tests — confirm RED (3 errors, undefined method `to_numbered`)
- [x] 2.3 GREEN — Implement `PathEntryList#to_numbered` and `PathEntryList.from_numbered`
- [x] 2.4 GREEN — Update `ChangesFile` to use numbered serialization
- [x] 2.5 GREEN — Update `INSTRUCTIONS` constant with reorder/number/dash-space guidance
- [x] 2.6 Run full suite — deferred to Slice 3 (existing tests broke as expected, fixed there)

### Slice 3: Number-based matching in Reen

- [x] 3.0 (combined with Slice 2 — baseline was 21 runs before numbered output broke existing tests)
- [x] 3.1 RED — Write failing tests in `spec/spec_reorder.rb`:
  - [x] 3.1a `Reen#request` correctly matches reordered entries to originals by number (reverse, rename+move)
  - [x] 3.1b `Reen#request` still raises error when lines are removed
- [x] 3.2 Run new tests — confirm RED (3.1a failed, 3.1b passed)
- [x] 3.3 GREEN — Changed `Reen#compare_lists` to use `PathEntryList.from_numbered` for number-keyed matching
- [x] 3.4 GREEN — Updated existing tests: delete/force-delete use `.sub("] ", "] - ")` pattern
- [x] 3.5 Run full suite — confirm all pass (27 runs, 110 assertions, 0 failures)

### Slice 4: Documentation

- [x] 4.1 Update README.md: documented numbered prefixes, dash-space syntax, reordering, programmatic examples
- [x] 4.2 CLI help in `bin/reen` — no changes needed (uses banner/options only, editing syntax is in INSTRUCTIONS)
- [x] 4.3 `ChangesFile::INSTRUCTIONS` — updated in Slice 2.5, verified

### Slice 5: Verification

- [x] 5.1 Run full suite (`bundle exec rake`) — 29 tests, 115 assertions, 0 failures. RuboCop: only pre-existing offenses, no new ones.
- [ ] 5.2 Manual verification with real editor (user to perform)

## Completed

- Slice 0: PathEntry/PathEntryList refactor — `PathEntry` wraps paths with filesystem queries, `PathEntryList` is an Enumerable collection. `Change` delegates to `PathEntry`. `Reen` and `ChangesFile` accept `PathEntryList`. All 17 tests pass.
- Slice 1: Dash-operator ambiguity fix — `Change#extract_request` now requires space after `-`/`--` for delete operators. `-file` is rename to `-file`, `- file` is delete. All 21 tests pass.
- Slice 2: Numbered prefixes — `PathEntryList#to_numbered` and `.from_numbered` implemented. `ChangesFile` writes `[NN] path` lines and updated `INSTRUCTIONS`.
- Slice 3: Number-based matching — `Reen#compare_lists` uses `from_numbered` for number-keyed matching instead of positional zip. Reordering works. All 27 tests pass (110 assertions).
- Slice 4: Documentation — README updated with numbered prefixes, dash-space syntax, reordering docs, programmatic examples. CLI help unchanged (banner only). INSTRUCTIONS verified.
- Slice 5: Verification — 29 tests, 115 assertions, 0 failures. No new RuboCop offenses. Manual editor test pending.

---

Last updated: 2026-03-10
