#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  params = option_parse
  params = {c: true, l: true, w: true} if params.empty?
  ARGV.empty? ? word_count_stdin(params) : word_count_files(params)
end

def option_parse
  opt = OptionParser.new
  params = {}
  opt.on('-c')
  opt.on('-l')
  opt.on('-w')
  opt.parse!(ARGV, into: params)
  params
end

def word_count_stdin(params)
  array_of_line = $stdin.readlines
  counts_map = build_counts_map(array_of_line)
  puts format_counts_map(counts_map, params).join
end

def build_counts_map(array_of_line)
  {
    line: count_line_number(array_of_line),
    word: count_word_number(array_of_line),
    byte: count_bytesize(array_of_line)
  }
end

def count_line_number(array_of_line)
  array_of_line.size
end

def count_word_number(array_of_line)
  array_of_line.map { |line| line.split(/[ \t\n]+/).size }.sum
end

def count_bytesize(array_of_line)
  array_of_line.map { |line| line.bytesize }.sum
end

def format_counts_map(counts_map, params)
  formatted_data = []
  formatted_data << " #{counts_map[:line].to_s.rjust(7)}" if params[:l]
  formatted_data << " #{counts_map[:word].to_s.rjust(7)}" if params[:w]
  formatted_data << " #{counts_map[:byte].to_s.rjust(7)}" if params[:c]
  formatted_data
end

def word_count_files(params)
  arrays_of_line = files_to_arrays_of_line
  counts_maps = arrays_of_line.map { |array_of_line| build_counts_map(array_of_line) }
  counts_maps.each_with_index do |counts_map, idx|
    puts format_counts_map_with_path(counts_map, idx, params).join
  end
  word_count_total(counts_maps, params) if ARGV.size >= 2
end

def files_to_arrays_of_line
  ARGV.map { |path| File.open(path) { |f| f.readlines } }
end

def format_counts_map_with_path(counts_map, idx, params)
  path = ARGV[idx]
  format_counts_map(counts_map, params) << " #{path}"
end

def word_count_total(counts_maps, params)
  total_counts_map = build_total_counts_map(counts_maps)
  print_total_counts(total_counts_map, params)
end

def build_total_counts_map(counts_maps)
  {
    line: counts_maps.map { |counts_map| counts_map[:line] }.sum,
    word: counts_maps.map { |counts_map| counts_map[:word] }.sum,
    byte: counts_maps.map { |counts_map| counts_map[:byte] }.sum
  }
end

def print_total_counts(total_counts_map, params)
  formatted_data = []
  formatted_data << " #{total_counts_map[:line].to_s.rjust(7)}" if params[:l]
  formatted_data << " #{total_counts_map[:word].to_s.rjust(7)}" if params[:w]
  formatted_data << " #{total_counts_map[:byte].to_s.rjust(7)}" if params[:c]
  formatted_data << " total\n"
  print formatted_data.join
end

exec
