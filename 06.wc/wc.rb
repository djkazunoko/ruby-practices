#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  options = parse_options
  options = { c: true, l: true, w: true } if options.empty?
  ARGV.empty? ? wc_stdin(options) : wc_files(options)
end

def parse_options
  opt = OptionParser.new
  options = {}
  opt.on('-c')
  opt.on('-l')
  opt.on('-w')
  opt.parse!(ARGV, into: options)
  options
end

def wc_stdin(options)
  lines = $stdin.readlines
  counts_map = build_counts_map(lines)
  puts format_counts_map(counts_map, options).join
end

def build_counts_map(lines)
  {
    line: count_line_number(lines),
    word: count_word_number(lines),
    byte: count_bytesize(lines)
  }
end

def count_line_number(lines)
  lines.size
end

def count_word_number(lines)
  lines.map { |line| line.split(/[ \t\n]+/).size }.sum
end

def count_bytesize(lines)
  lines.map(&:bytesize).sum
end

def format_counts_map(counts_map, options)
  formatted_data = []
  formatted_data << " #{counts_map[:line].to_s.rjust(7)}" if options[:l]
  formatted_data << " #{counts_map[:word].to_s.rjust(7)}" if options[:w]
  formatted_data << " #{counts_map[:byte].to_s.rjust(7)}" if options[:c]
  formatted_data
end

def wc_files(options)
  arrays_of_lines = files_to_arrays_of_lines
  counts_maps = arrays_of_lines.map { |lines| build_counts_map(lines) }
  counts_maps.each_with_index do |counts_map, idx|
    puts format_counts_map_with_path(counts_map, idx, options).join
  end
  wc_total(counts_maps, options) if ARGV.size >= 2
end

def files_to_arrays_of_lines
  ARGV.map { |path| File.readlines(path) }
end

def format_counts_map_with_path(counts_map, idx, options)
  path = ARGV[idx]
  format_counts_map(counts_map, options) << " #{path}"
end

def wc_total(counts_maps, options)
  total_counts_map = build_total_counts_map(counts_maps)
  print_total_counts(total_counts_map, options)
end

def build_total_counts_map(counts_maps)
  {
    line: counts_maps.map { |counts_map| counts_map[:line] }.sum,
    word: counts_maps.map { |counts_map| counts_map[:word] }.sum,
    byte: counts_maps.map { |counts_map| counts_map[:byte] }.sum
  }
end

def print_total_counts(total_counts_map, options)
  formatted_data = []
  formatted_data << " #{total_counts_map[:line].to_s.rjust(7)}" if options[:l]
  formatted_data << " #{total_counts_map[:word].to_s.rjust(7)}" if options[:w]
  formatted_data << " #{total_counts_map[:byte].to_s.rjust(7)}" if options[:c]
  formatted_data << " total\n"
  print formatted_data.join
end

exec
