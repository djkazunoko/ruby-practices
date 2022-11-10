# frozen_string_literal: true

module LS
  class LongFormatter
    def initialize(files)
      @files = files
      @max_length_map = max_length_map(@files)
      @block_total = @files.map(&:blocks).sum
    end

    def list_files
      puts "total #{@block_total}"
      @files.each { |file| print_long_format(file, @max_length_map) }
    end

    private

    def max_length_map(files)
      {
        nlink: files.map { |file| file.nlink.size }.max,
        username: files.map { |file| file.username.size }.max,
        groupname: files.map { |file| file.groupname.size }.max,
        bytesize: files.map { |file| file.bytesize.size }.max
      }
    end

    def print_long_format(file, max_length_map)
      print [
        "#{file.type}#{file.mode} ",
        "#{file.nlink.rjust(max_length_map[:nlink])} ",
        "#{file.username.ljust(max_length_map[:username])}  ",
        "#{file.groupname.ljust(max_length_map[:groupname])}  ",
        "#{file.bytesize.rjust(max_length_map[:bytesize])} ",
        "#{file.mtime} ",
        "#{file.pathname}\n"
      ].join
    end
  end
end
