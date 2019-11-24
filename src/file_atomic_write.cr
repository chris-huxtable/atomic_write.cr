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

require "file_utils"


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
  def self.atomic_write(path : String, perm = DEFAULT_CREATE_MODE, encoding = nil, invalid = nil, *, append : Bool = false, &block : IO::FileDescriptor -> Nil) : Bool
    atomic_path = new_atomic_path(path)
    success_flag = false

    begin
      open(atomic_path, "w", perm, encoding, invalid) do |fd|
        fd.flock_exclusive() do
          open(path, "r") { |src| IO.copy(src, fd) } if append
          yield(fd)
          fd.flush()
          success_flag = true
        end
      end
    ensure
      if ( success_flag )
        atomic_install(atomic_path, path)
      else
        delete(atomic_path)
      end
    end

    return success_flag
  end

  # Writes the provided content completely or not at all preventing file corruption.
  #
  # This is preformed in the same way as `atomic_write` with block.
  #
  # NOTE: If the content is a `Slice(UInt8)`, those bytes will be written.
  # If it's an `IO`, all bytes from the `IO` will be written.
  # Otherwise, the string representation of *content* will be written
  # (the result of invoking `to_s` on *content*).
  def self.atomic_write(path : String, content, perm = DEFAULT_CREATE_MODE, encoding = nil, invalid = nil) : Bool
    atomic_write(path, perm, encoding, invalid) do |fd|
      case content
      when Bytes then fd.write(content)
      when IO    then IO.copy(content, fd)
      else            fd.print(content)
      end
    end
  end

  # :nodoc:
  protected def self.atomic_install(atomic_path : String, dest_path : String) : Nil
    if ( exists?(dest_path) )
      stat = stat(dest_path)
      chmod(atomic_path, stat.mode)
      chown(atomic_path, stat.uid, stat.gid)
    end
    rename(atomic_path, dest_path)
  end

  # :nodoc:
  protected def self.new_atomic_path(path : String, length : Int::Unsigned = 16_u8, limit : Int::Unsigned = 8_u8) : String
    atomic_path = "#{path}.atomic_#{Random::Secure.urlsafe_base64(length)}"

    while ( exists?(atomic_path) )
      raise "Failed to generate temporary path." if ( limit <= 0 )
      atomic_path = "#{path}.atomic_#{Random::Secure.urlsafe_base64(length)}"
      limit -= 1
    end

    return atomic_path
  end

end
