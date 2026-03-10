# Reen

Reen is a utility written in Ruby (requires Ruby installed on your machine) that mass renames/deletes files by allowing the user to modify a list. It includes a command line executable called `reen` that opens the user's default editor to permit interactive changes, or can be used programatically by modifying the list of file names using a code block.

[![Reen usage introduction](https://img.youtube.com/vi/yJfDRfJr3os/0.jpg)](https://www.youtube.com/watch?v=yJfDRfJr3os)

## Installation

To install the command line utility, use:

    $ gem install reen

Or add this line to your Ruby application's Gemfile for programmatic use:

```ruby
gem 'reen'
```

## Usage

### Command line

From command line, run `reen` with file list:

    reen files [options]

where `files` are a list of files or wildcard pattern (defaults to `*`; see examples)

Options include:

- `--help` or `-h` to see options help
- `--editor [EDITOR]` or `-e [EDITOR]` to use a specific editor, or just `-e` to use `$EDITOR`
- `--visual [EDITOR]` or `-v [EDITOR]` to use a specific editor, or just `-v` to use `$VISUAL`
- `--review` or `-r` request to review and confirm changes

The editor must block until the file is closed — for VS Code use `'code -w'`, for Sublime use `'subl -w'`. Without `-e` or `-v`, Reen defaults to `$VISUAL` then `$EDITOR`.

Examples:

    reen                    # reen all files (*)
    reen **/*               # reen all files in all subfolders
    reen myfolder/**/*.mov  # reen all mov files in subfolders
    reen -e                 # reen all files using $EDITOR
    reen -v                 # reen all files using $VISUAL
    reen -e vi *.md         # reen all markdown files using vi
    reen --editor 'code -w' # reen all files using vscode

### Specifying changes through the editor

Upon running Reen on file list, your editor will open with a numbered list of file/folder names. Each line has a number prefix like `[01]` that tracks the original file. For example:

```
[01] LICENSE.txt
[02] README.md
[03] SETUP.txt
[04] bin
[05] bin/help
[06] bin/myexec
[07] tests
[08] tests/fixtures
[09] tests/fixtures/a.json
[10] tests/fixtures/b.json
[11] tests/fixtures/c.json
[12] tests/helper.code
[13] tests/tests.code
```

Specify changes to each file you wish changed modifying it in your editor:

- Change the file/folder name (after the number prefix) to rename it
- Put `- ` (dash followed by a space) after the number prefix to delete a file or empty folder
- Put `-- ` (double dash followed by a space) to force delete a file or non-empty folder (recursively)
- You may freely reorder lines — the number prefixes track which original file each line refers to
- Do not change or remove the `[NN]` number prefixes

For example, if we wanted to (a) rename `LICENSE.txt` to `LICENSE.md`, (b) delete `SETUP.txt`, and (c) recursively delete the `bin/` folder:

```
[01] LICENSE.md
[02] README.md
[03] - SETUP.txt
[04] -- bin
[05] bin/help
[06] bin/myexec
[07] tests
[08] tests/fixtures
[09] tests/fixtures/a.json
[10] tests/fixtures/b.json
[11] tests/fixtures/c.json
[12] tests/helper.code
[13] tests/tests.code
```

Note: filenames starting with dashes (e.g., `-myfile`) are safe — only a dash followed by a space triggers deletion.

Upon saving and exiting the editor, Reen will execute all the changes.

### Ruby application

Use Reen programmatically using the `reen` gem. In the example below, we specify that we do not want to use an actual editor to modify the list, but rather alter the list file using a block. Note that `file.list` contains numbered lines (e.g., `[1] LICENSE.txt`).

```ruby
require 'reen'

glob = Dir.glob("*")
reen = Reen::Reen.new(editor: nil)

reen.execute(glob) do |file|
  # Rename LICENSE.txt -> LICENSE.md (gsub works on the path portion)
  index = file.list.index { |l| l.include? "LICENSE.txt" }
  file.list[index] = file.list[index].gsub("txt", "md")

  # Delete a file — insert "- " after the number prefix
  index = file.list.index { |l| l.include? "SETUP.txt" }
  file.list[index] = file.list[index].sub("] ", "] - ")
end
```

You may also pass a block with an editor specified, in which case the block is run after the editor has finished.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soumyaray/reen.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
