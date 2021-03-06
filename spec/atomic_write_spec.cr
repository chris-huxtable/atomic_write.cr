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

require "spec"

require "../src/atomic_write"

describe File do
  describe "atomic_write" do
    it "writes atomically" do
      filename = File.tempfile("atomic_write").path
      begin
        File.atomic_write(filename) { |fd| fd << "hello" }
        File.read(filename).should eq("hello")
      ensure
        File.delete(filename)
      end
    end

    it "appends atomically" do
      filename = File.tempfile("atomic_write").path
      begin
        File.atomic_write(filename) { |fd| fd << "hello" }
        File.read(filename).should eq("hello")

        File.atomic_write(filename, append: true) { |fd| fd << " world" }
        File.read(filename).should eq("hello world")
      ensure
        File.delete(filename)
      end
    end

    it "copies atomically" do
      filename = File.tempfile("atomic_write").path
      copyname = filename + ".copy"
      begin
        File.atomic_write(filename) { |fd| fd << "hello" }
        File.read(filename).should eq("hello")

        File.atomic_copy(filename, copyname)
        File.read(copyname).should eq("hello")
      ensure
        File.delete(filename)
        File.delete(copyname)
      end
    end

    it "replaces atomically" do
      filename = File.tempfile("atomic_write").path
      begin
        File.write(filename, "world")
        File.atomic_replace(filename) do |src, dst|
          dst << "hello "
          IO.copy src, dst
        end
        File.read(filename).should eq("hello world")
      ensure
        File.delete(filename)
      end
    end
  end
end
