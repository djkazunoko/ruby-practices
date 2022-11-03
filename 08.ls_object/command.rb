# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'path'
require_relative 'long_formatter'
require_relative 'short_formatter'

module LS
  class Command
    def initialize(argv)
      @params = argv.getopts('alr')
      @target_dir = Pathname(argv[0] || '.')
    end

    def list_paths
      path_objects = get_paths
      @params['l'] ? LongFormatter.new(path_objects).list : ShortFormatter.new(path_objects).list
    end

    private

    def get_paths
      pattern = @target_dir.join('*')
      paths = @params['a'] ? Dir.glob(pattern, File::FNM_DOTMATCH) : Dir.glob(pattern)
      paths = paths.reverse if @params['r']
      path_objects = paths.map { |path| Path.new(path) }
    end
  end
end
