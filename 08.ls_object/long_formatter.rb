# frozen_string_literal: true

module LS
  class LongFormatter
    def initialize(path_objects)
      @path_objects = path_objects
      @max_length_map = get_max_length_map(@path_objects)
      @block_total = @path_objects.map { |path_object| path_object.blocks }.sum
    end

    def list
      puts "total #{@block_total}"
      @path_objects.each { |path_object| print_long_format(path_object, @max_length_map) }
    end

    private

    def get_max_length_map(path_objects)
      {
        nlink: path_objects.map { |path_object| path_object.nlink.size }.max,
        username: path_objects.map { |path_object| path_object.username.size }.max,
        groupname: path_objects.map { |path_object| path_object.groupname.size }.max,
        bitesize: path_objects.map { |path_object| path_object.bitesize.size }.max
      }
    end

    def print_long_format(path_object, max_length_map)
      print [
        "#{path_object.type}#{path_object.mode} ",
        "#{path_object.nlink.rjust(max_length_map[:nlink])} ",
        "#{path_object.username.ljust(max_length_map[:username])}  ",
        "#{path_object.groupname.ljust(max_length_map[:groupname])}  ",
        "#{path_object.bitesize.rjust(max_length_map[:bitesize])} ",
        "#{path_object.mtime} ",
        "#{path_object.pathname}\n"
      ].join
    end
  end
end
