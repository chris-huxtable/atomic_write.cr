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

require "./spec_helper"


private ATOMIC_TEST = "/tmp/file_atomic_write_spec.test"

describe File do

	it "atomic_write and atomic_append" do
		File.atomic_write(ATOMIC_TEST) { |fd| fd << "hello" }
		File.read(ATOMIC_TEST).should eq("hello")

		File.atomic_append(ATOMIC_TEST) { |fd| fd << " world" }
		File.read(ATOMIC_TEST).should eq("hello world")

		File.delete(ATOMIC_TEST)
	end

end
