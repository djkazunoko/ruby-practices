# frozen_string_literal: true

require 'optparse'
require 'pathname'
require_relative 'file_stat'
require_relative 'long_formatter'
require_relative 'short_formatter'

module LS
  class Command
    def initialize(argv)
      @params = argv.getopts('alr')
      @target_dir = Pathname(argv[0] || '.')
    end

    def list_files
      files = build_files
      @params['l'] ? LongFormatter.new(files).list_files : ShortFormatter.new(files).list_files
    end

    private

    def build_files
      pattern = @target_dir.join('*')
      paths = @params['a'] ? Dir.glob(pattern, File::FNM_DOTMATCH) : Dir.glob(pattern)
      paths = paths.reverse if @params['r']
      paths.map { |path| FileStat.new(path) }
    end
  end
end
