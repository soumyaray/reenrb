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

    reen [file ...]

Examples:

    reen *
    reen myfolder/**/*.mov

### Ruby application

Use programmatically using the `reenrb` gem. In the example below, we specify that we do not want to use an actual editor to modify the list, but rather alter the list file using a block.

```ruby
require 'reenrb'

glob = Dir.glob("*")
reen = Reenrb::Reen.new(editor: nil)

reen.execute(glob) do |tmpfile_path|
  lines = File.read(tmpfile_path).split("\n")

  # Rename LICENSE.txt -> LICENSE.md
  index = lines.index { |l| l.include? "LICENSE.txt" }
  lines[index] = lines[index].gsub("txt", "md")
  File.write(tmpfile_path, lines.join("\n"))
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/soumyaray/reenrb.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
