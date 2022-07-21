#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require 'etc'

MAX_NUMBER_OF_COLUMNS = 3
params = ARGV.getopts('l')

def display_files(params, max_number_of_columns)
  files = Dir.glob('*', base: './')

  if params['l']
    files.each do |file|
      fs = File.stat(file)
      file_mode = fs.mode
      number_of_links = fs.nlink
      owner_name = Etc.getpwuid(fs.uid).name
      group_name = Etc.getgrgid(fs.gid).name
      file_size = fs.size
      last_modified_time = fs.mtime.strftime("%_m %_d %H:%M")
      pathname = file
      print "#{file_mode}  #{number_of_links} #{owner_name}  #{group_name}  #{file_size}  #{last_modified_time} #{pathname}\n"
    end
  else
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
end

def calc_number_of_rows(number_of_elements, max_number_of_columns)
  if (number_of_elements % max_number_of_columns).zero?
    number_of_elements / max_number_of_columns
  else
    (number_of_elements / max_number_of_columns) + 1
  end
end

display_files(params, MAX_NUMBER_OF_COLUMNS)
