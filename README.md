# Reenrb

Reen-rb is a utility written in Ruby (requires Ruby installed on your machine) that mass renames/deletes files by allowing the user to modify a list. It includes a command line executable called `reen` that opens the user's default editor to permit interactive changes, or can be used programatically by modifying the list of file names using a code block.

[![Reen usage introduction](https://img.youtube.com/vi/yJfDRfJr3os/0.jpg)](https://www.youtube.com/watch?v=yJfDRfJr3os)

## Installation

To install the command line utility, use:

    $ gem install reenrb

Or add this line to your Ruby application's Gemfile for programmatic use:

```ruby
gem 'reenrb'
```

## Usage

### Command line

From command line, run `reen` with file list:

    reen files [options]

where `files` are a list of files or wildcard pattern (defaults to `*`; see examples)

Options include:

- `--help` or `-h`' to see options help
- `--editor EDITOR` or `-e EDITOR`' to set the editor (defaults to $VISUAL or $EDITOR otherwise) such as `emacs` or `vi`. For Visual Studio Code use `'code -w'` to block until editor finishes.
- `--review` or `-r` request to review and confirm changes

Examples:

    reen                    # reen all files (*)
    reen **/*               # reen all files in all subfolders
    reen myfolder/**/*.mov  # reen all mov files in subfolders
    reen *.md --editor vi   # reen all markdown files using vi
    reen --editor 'code -w' # reen all markdown files using vscode

### Specifying changes through the editor

Upon running Reen on file list, your editor will open with a list of file/folder names. For example:

```
LICENSE.txt
README.md
SETUP.txt
bin
bin/help
bin/myexec
tests
tests/fixtures
tests/fixtures/a.json
tests/fixtures/b.json
tests/fixtures/c.json
tests/helper.code
tests/tests.code
```

Specify changes to each file you wish changed modifying it in your editor:

- Change the file/folder name to rename it (the rename could cause a move if you change its path; restrictions will be reported)
- Prepend using `-` to delete a file or empty folder
- Prepend using `--` to force delete a file or non-empty folder (recursively)

For example, if we wanted to change the above list of files/folders in the editor to (a) rename `LICENSE.txt` to `LICENSE.md`, (b) delete `SETUP.txt`, and (c) recursively delete the `bin/` folder, then we would change the filenames to look like:

```
LICENSE.md
README.md
-SETUP.txt
--bin
bin/help
bin/myexec
tests
tests/fixtures
tests/fixtures/a.json
tests/fixtures/b.json
tests/fixtures/c.json
tests/helper.code
tests/tests.code
```

Upon saving and exiting the editor, Reen will execute all the changes.

### Ruby application

Use Reen programmatically using the `reenrb` gem. In the example below, we specify that we do not want to use an actual editor to modify the list, but rather alter the list file using a block.

```ruby
require 'reenrb'

glob = Dir.glob("*")
reen = Reenrb::Reen.new(editor: nil)

reen.execute(glob) do |file|
  # Rename LICENSE.txt -> LICENSE.md
  index = file.list.index { |l| l.include? "LICENSE.txt" }
  file.list[index] = file.list[index].gsub("txt", "md")
end
```

You may also pass a block with an editor specified, in which case the block is run after the editor has finished.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soumyaray/reenrb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
