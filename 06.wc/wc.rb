#!/usr/bin/env ruby
# frozen_string_literal: true

def exec
  if ARGV.empty?
    word_count_stdin
  else
    word_count_files
  end
end

def word_count_stdin
  array_of_line = $stdin.readlines
  counts_map = build_counts(array_of_line)
  puts format_counts(counts_map).join
end

def build_counts(array_of_line)
  {
    line: count_line_number(array_of_line).to_s,
    word: count_word_number(array_of_line).to_s,
    byte: count_bytesize(array_of_line).to_s
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

def format_counts(counts_map)
  [
    " #{counts_map[:line].rjust(7)}",
    " #{counts_map[:word].rjust(7)}",
    " #{counts_map[:byte].rjust(7)}"
  ]
end

def word_count_files
  arrays_of_line = files_to_arrays_of_line
  counts_maps = arrays_of_line.map { |array_of_line| build_counts(array_of_line) }
  counts_maps.each_with_index do |counts_map, idx|
    puts format_counts_with_path(counts_map, idx).join
  end
end

def files_to_arrays_of_line
  ARGV.map { |path| File.open(path) { |f| f.readlines } }
end

def format_counts_with_path(counts_map, idx)
  path = ARGV[idx]
  format_counts(counts_map).push " #{path}"
end

exec
