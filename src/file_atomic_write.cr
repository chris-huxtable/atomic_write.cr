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

	protected def self.new_atomic_path(path : String, length : Int::Unsigned = 16_u8) : String
		name = "#{path}.atomic_#{Random::Secure.urlsafe_base64(length)}"

		limit = 10
		while ( File.exists?(name) )
			raise "Failed to generate temporary path." if ( limit <= 0 )
			name = "#{path}.atomic_#{Random::Secure.urlsafe_base64(length)}"
			limit -= 1
		end

		return name
	end

	def self.atomic_write(path : String, perm = DEFAULT_CREATE_MODE, encoding = nil, invalid = nil) : Bool
		atomic_path = new_atomic_path(path)
		success_flag = false

		stat = File.stat(path) if ( File.exists?(path) )

		begin
			File.open(atomic_path, "w", perm, encoding, invalid) { |fd|
				fd.flock_exclusive() {
					yield(fd)
					success_flag = true

					fd.flush()
				}
			}
		ensure
			if ( !success_flag )
				File.delete(atomic_path)
			else
				if ( stat )
					File.chmod(atomic_path, stat.mode)
					File.chown(atomic_path, stat.uid, stat.gid)
				end

				File.rename(atomic_path, path)
			end
		end

		return success_flag
	end

	def self.atomic_append(path : String, perm = DEFAULT_CREATE_MODE, encoding = nil, invalid = nil) : Bool
		atomic_path = new_atomic_path(path)
		success_flag = false

		if ( File.exists?(path) )
			stat = File.stat(path)
			FileUtils.cp(path, atomic_path)
		end

		begin
			File.open(atomic_path, "a", perm, encoding, invalid) { |fd|
				fd.flock_exclusive() {
					yield(fd)
					success_flag = true

					fd.flush()
				}
			}
		ensure
			if ( !success_flag )
				File.delete(atomic_path)
			else
				if ( stat )
					File.chmod(atomic_path, stat.mode)
					File.chown(atomic_path, stat.uid, stat.gid)
				end

				File.rename(atomic_path, path)
			end
		end

		return success_flag
	end
end
