# atomic_write.cr
[![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://chris-huxtable.github.io/atomic_write.cr/)
[![GitHub release](https://img.shields.io/github/release/chris-huxtable/atomic_write.cr.svg)](https://github.com/chris-huxtable/atomic_write.cr/releases)
[![Crystal CI](https://github.com/chris-huxtable/atomic_write.cr/actions/workflows/crystal.yml/badge.svg)](https://github.com/chris-huxtable/atomic_write.cr/actions/workflows/crystal.yml)

Extends `File` to provide `atomic_write()`, `atomic_replace()`.

An atomic write creates a new file at a temporary path. It then writes the new
file contents to that file. Lastly it renames it to the original path. This dramatically
reduces the opportunity for file corruption.


## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  atomic_write:
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

Atomic copy:

```crystal
File.atomic_copy("some/src/path", "some/dst/path")
```

Atomic replace:

```crystal
File.atomic_replace("some/src/path") { |src_fd, dst_fd| dst_fd << "hello" << src_fd.gets_to_end }
```


## Contributing

1. Fork it ( https://github.com/chris-huxtable/atomic_write.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request


## Contributors

- [Chris Huxtable](https://github.com/chris-huxtable) - creator, maintainer
