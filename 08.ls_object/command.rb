# frozen_string_literal: true

require 'optparse'
require_relative 'long_formatter'
require_relative 'short_formatter'

module LS
  class Command
    def initialize(argv)
      @params = argv.getopts('alr')
    end

    def list_paths
      paths = get_paths(dotmatch: @params['a'])
      paths = paths.reverse if @params['r']
      @params['l'] ? LongFormatter.new(paths).list : ShortFormatter.new(paths).list
    end

    private

    def get_paths(dotmatch: false)
      dotmatch ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    end
  end
end
