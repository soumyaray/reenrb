# Reenrb

Reen-rb is a utility written in Ruby (requires Ruby installed on your machine) that mass renames/deletes files by allowing the user to modify a list. It includes a command line executable called `reen` that opens the user's default editor to permit interactive changes, or can be used programatically by modifying the list of file names using a code block.

## Installation

To install the command line utility, use:

    $ gem install reenrb

Or add this line to your Ruby application's Gemfile for programmatic use:

```ruby
gem 'reenrb'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install reenrb

## Usage

### Command line

From command line, run `reen` with file list:

    reen [files=* ...] [options]

where `files` are a list of files or wildcard pattern (defaults to `*`; see examples)

Options include:

- `--help` or `-h`' to see options help
- `--editor EDITOR` or `-e EDITOR`' to set the editor (defaults to $VISUAL or $EDITOR otherwise) such as `emacs` or `vi`. For Visual Studio Code use `'code -w'` to block until editor finishes.
- `--review` or `-r` request to review and confirm changes

Examples:

    reen **/*
    reen myfolder/**/*.mov
    reen *.md --editor vi
    reen --editor 'code -w'

### Ruby application

Use programmatically using the `reenrb` gem. In the example below, we specify that we do not want to use an actual editor to modify the list, but rather alter the list file using a block.

```ruby
require 'reenrb'

glob = Dir.glob("*")
reen = Reenrb::Reen.new(editor: nil)

reen.execute(glob) do |lines|
  # Rename LICENSE.txt -> LICENSE.md
  index = lines.index { |l| l.include? "LICENSE.txt" }
  lines[index] = lines[index].gsub("txt", "md")
  lines
end
```

You may also pass a block with an editor specified, in which case the block is run after the editor has finished.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soumyaray/reenrb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
