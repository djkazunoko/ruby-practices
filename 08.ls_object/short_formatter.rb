# frozen_string_literal: true

module LS
  class ShortFormatter
    COLUMN_NUMBER = 3

    def initialize(files)
      @files = files
    end

    def list_files
      element_number = @files.size.to_f
      max_length = @files.map { |file| file.basename.size }.max
      row_number = (element_number / COLUMN_NUMBER).ceil
      lines = Array.new(row_number) { [] }
      @files.each_with_index do |file, index|
        line_number = index % row_number
        lines[line_number].push(file.basename.ljust(max_length + 2))
      end
      lines.each { |line| puts line.join }
    end
  end
end
