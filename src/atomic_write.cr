# Copyright (c) 2018 Christian Huxtable <chris@huxtable.ca>.
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

class File
  # Ensures the content written to the file descriptor is written completely or not at all
  # preventing corruption of the file.
  #
  # If a file is being created, its initial permissions may be set using the *perm* parameter.
  # Then the given block will be passed the opened file descriptor as an argument, the file will
  # be automatically closed and saved when the block returns.
  #
  # This is done by saving the new contents at temporary path. When the new content is
  # successfully written the temporary path is changed to the provided path ensuring the data is
  # not corrupted. If the write fails the temporary file is deleted.
  def self.atomic_write(path : String, perm = DEFAULT_CREATE_MODE, encoding = nil, invalid = nil, *, append : Bool = false, &block : IO::FileDescriptor -> Nil) : Nil
    atomic_path = "#{path}.atomic_#{Random::Secure.urlsafe_base64(16)}"
    raise "Failed to generate temporary path, exists" if exists?(atomic_path)

    open(atomic_path, "w", perm, encoding, invalid) do |fd|
      fd.flock_exclusive do
        open(path, "r") { |src| IO.copy(src, fd) } if append
        yield(fd)
        fd.flush
      end
    rescue ex
      delete(atomic_path)
      raise ex
    end

    if exists?(path)
      stat = stat(path)
      chmod(atomic_path, stat.mode)
      chown(atomic_path, stat.uid, stat.gid)
    end
    rename(atomic_path, path)
  end

  # Writes the provided content completely or not at all preventing file corruption.
  #
  # This is preformed in the same way as `atomic_write` with block.
  #
  # NOTE: If the content is a `Slice(UInt8)`, those bytes will be written.
  # If it's an `IO`, all bytes from the `IO` will be written.
  # Otherwise, the string representation of *content* will be written
  # (the result of invoking `to_s` on *content*).
  def self.atomic_write(path : String, content, perm = DEFAULT_CREATE_MODE, encoding = nil, invalid = nil) : Nil
    atomic_write(path, perm, encoding, invalid) do |fd|
      case content
      when Bytes then fd.write(content)
      when IO    then IO.copy(content, fd)
      else            fd.print(content)
      end
    end
  end
end
