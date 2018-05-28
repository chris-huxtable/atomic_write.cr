# atomic_write.cr

Extends`File` to provide `atomic_write()`.

An atomic write creates a new file at a temporary path. It then writes the new
file contents to that file. Lastly it renames it to the original path. This dramatically
reduces the opportunity for file corruption.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  file_atomic_write:
    github: chris-huxtable/atomic_write.cr
```


## Usage

```crystal
require "atomic_write"
```

Atomic write:

```crystal
File.atomic_write("some/path") { |fd| fd << "hello world" }
```

Atomic append:

```crystal
File.atomic_write("some/path", append: true) { |fd| fd << "hello world" }
```


## Contributing

1. Fork it ( https://github.com/chris-huxtable/atomic_write.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [Chris Huxtable](https://github.com/chris-huxtable) - creator, maintainer
