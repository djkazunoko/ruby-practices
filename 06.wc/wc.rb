#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  params = option_parse
  params = { c: true, l: true, w: true } if params.empty?
  ARGV.empty? ? wc_stdin(params) : wc_files(params)
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

def wc_stdin(params)
  array_of_lines = $stdin.readlines
  counts_map = build_counts_map(array_of_lines)
  puts format_counts_map(counts_map, params).join
end

def build_counts_map(array_of_lines)
  {
    line: count_line_number(array_of_lines),
    word: count_word_number(array_of_lines),
    byte: count_bytesize(array_of_lines)
  }
end

def count_line_number(array_of_lines)
  array_of_lines.size
end

def count_word_number(array_of_lines)
  array_of_lines.map { |line| line.split(/[ \t\n]+/).size }.sum
end

def count_bytesize(array_of_lines)
  array_of_lines.map(&:bytesize).sum
end

def format_counts_map(counts_map, params)
  formatted_data = []
  formatted_data << " #{counts_map[:line].to_s.rjust(7)}" if params[:l]
  formatted_data << " #{counts_map[:word].to_s.rjust(7)}" if params[:w]
  formatted_data << " #{counts_map[:byte].to_s.rjust(7)}" if params[:c]
  formatted_data
end

def wc_files(params)
  arrays_of_lines = files_to_arrays_of_lines
  counts_maps = arrays_of_lines.map { |array_of_lines| build_counts_map(array_of_lines) }
  counts_maps.each_with_index do |counts_map, idx|
    puts format_counts_map_with_path(counts_map, idx, params).join
  end
  wc_total(counts_maps, params) if ARGV.size >= 2
end

def files_to_arrays_of_lines
  # ARGV.map { |path| File.open(path) { |f| f.readlines } }
  ARGV.map { |path| File.open(path).call(&:readlines) }
end

def format_counts_map_with_path(counts_map, idx, params)
  path = ARGV[idx]
  format_counts_map(counts_map, params) << " #{path}"
end

def wc_total(counts_maps, params)
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
