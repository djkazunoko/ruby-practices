# frozen_string_literal: true

require_relative 'path'

module LS
  class LongFormatter
    def initialize(paths)
      @long_formats = paths.map { |path| get_long_format(path) }
      @max_length_map = get_max_length_map(@long_formats)
      @block_total = @long_formats.map { |long_format| long_format.blocks }.sum
    end

    def list
      puts "total #{@block_total}"
      @long_formats.each { |long_format| print_long_format(long_format, @max_length_map) }
    end

    private

    def get_long_format(path)
      Path.new(path)
    end

    def get_max_length_map(long_formats)
      {
        nlink: long_formats.map { |long_format| long_format.nlink.size }.max,
        username: long_formats.map { |long_format| long_format.username.size }.max,
        groupname: long_formats.map { |long_format| long_format.groupname.size }.max,
        bitesize: long_formats.map { |long_format| long_format.bitesize.size }.max
      }
    end

    def print_long_format(long_format, max_length_map)
      print [
        "#{long_format.type}#{long_format.mode} ",
        "#{long_format.nlink.rjust(max_length_map[:nlink])} ",
        "#{long_format.username.ljust(max_length_map[:username])}  ",
        "#{long_format.groupname.ljust(max_length_map[:groupname])}  ",
        "#{long_format.bitesize.rjust(max_length_map[:bitesize])} ",
        "#{long_format.mtime} ",
        "#{long_format.pathname}\n"
      ].join
    end
  end
end
