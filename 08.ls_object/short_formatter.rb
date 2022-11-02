# frozen_string_literal: true

COLUMN_NUMBER = 3

module LS
  class ShortFormatter
    def initialize(paths)
      @paths = paths
    end

    def list
      element_number = @paths.size.to_f
      max_length = @paths.map(&:size).max
      row_number = (element_number / COLUMN_NUMBER).ceil
      lines = Array.new(row_number) { [] }
      @paths.each_with_index do |path, index|
        line_number = index % row_number
        lines[line_number].push(path.ljust(max_length + 2))
      end
      lines.each { |line| puts line.join }
    end
  end
end
