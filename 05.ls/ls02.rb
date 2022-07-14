#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

params = ARGV.getopts('a')

def display_files(params, max_number_of_columns)
  files = get_files(params)
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

def get_files(params)
  if params['a']
    Dir.glob('*', File::FNM_DOTMATCH, base: './')
  else
    Dir.glob('*', base: './')
  end
end

def calc_number_of_rows(number_of_elements, max_number_of_columns)
  if (number_of_elements % max_number_of_columns).zero?
    number_of_elements / max_number_of_columns
  else
    (number_of_elements / max_number_of_columns) + 1
  end
end

display_files(params, 3)
