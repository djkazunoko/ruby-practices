# frozen_string_literal: true

require 'optparse'
require_relative 'long_formatter'
require_relative 'short_formatter'

module LS
  class Command
    def initialize(argv)
      @params = argv.getopts('alr')
      @path_objects = get_paths
    end

    def list_paths
      @params['l'] ? LongFormatter.new(@path_objects).list : ShortFormatter.new(@path_objects).list
    end

    private

    def get_paths
      paths = @params['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
      paths = paths.reverse if @params['r']
      path_objects = paths.map { |path| Path.new(path) }
    end
  end
end
