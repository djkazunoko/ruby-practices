#!/usr/bin/env ruby
# frozen_string_literal: true

MAX_NUMBER_OF_COLUMNS = 3

def display_files(max_number_of_columns)
  files = Dir.glob('*', base: './')
  number_of_elements = files.size
  max_number_of_words = files.map(&:size).max
  number_of_rows = calc_number_of_rows(number_of_elements, max_number_of_columns)
  number_of_rows.times do |i|
    i.step(number_of_elements - 1, number_of_rows) do |n|
      print files[n].ljust(max_number_of_words + 2)
    end
    print "\n"
  end
end

def calc_number_of_rows(number_of_elements, max_number_of_columns)
  if (number_of_elements % max_number_of_columns).zero?
    number_of_elements / max_number_of_columns
  else
    (number_of_elements / max_number_of_columns) + 1
  end
end

display_files(MAX_NUMBER_OF_COLUMNS)
