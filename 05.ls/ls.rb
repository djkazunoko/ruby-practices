#!/usr/bin/env ruby
# frozen_string_literal: true

files = Dir.glob('*', base: './')
number_of_elements = files.size
max_number_of_columns = 3
number_of_rows = if (number_of_elements % max_number_of_columns).zero?
                   number_of_elements / max_number_of_columns
                 else
                   (number_of_elements / max_number_of_columns) + 1
                 end
column_width = files.map(&:size).max + 2

number_of_rows.times do |i|
  while i < number_of_elements
    print files[i].ljust(column_width)
    i += number_of_rows
  end
  print "\n"
end
