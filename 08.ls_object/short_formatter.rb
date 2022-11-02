# frozen_string_literal: true

COLUMN_NUMBER = 3

module LS
  class ShortFormatter
    def initialize(path_objects)
      @path_objects = path_objects
    end

    def list
      element_number = @path_objects.size.to_f
      max_length = @path_objects.map { |path_object| path_object.name.size}.max
      row_number = (element_number / COLUMN_NUMBER).ceil
      lines = Array.new(row_number) { [] }
      @path_objects.each_with_index do |path_object, index|
        line_number = index % row_number
        lines[line_number].push(path_object.name.ljust(max_length + 2))
      end
      lines.each { |line| puts line.join }
    end
  end
end
