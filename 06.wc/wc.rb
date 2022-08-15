#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  options = parse_options
  options = { c: true, l: true, w: true } if options.empty?
  paths = ARGV
  paths.empty? ? display_word_count_from_stdin(options) : display_word_count_from_files(paths, options)
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

def display_word_count_from_stdin(options)
  lines = $stdin.readlines
  word_count_map = build_word_count_map(lines)
  display_word_count(word_count_map, options)
end

def build_word_count_map(lines, path = '')
  {
    number_of_lines: count_line(lines),
    number_of_words: count_word(lines),
    bytesize: count_bytesize(lines),
    path: path
  }
end

def count_line(lines)
  lines.size
end

def count_word(lines)
  lines.sum { |line| line.split(/[ \t\n]+/).size }
end

def count_bytesize(lines)
  lines.sum(&:bytesize)
end

def display_word_count(word_count_map, options)
  word_counts = []
  word_counts << format_word_count(word_count_map[:number_of_lines]) if options[:l]
  word_counts << format_word_count(word_count_map[:number_of_words]) if options[:w]
  word_counts << format_word_count(word_count_map[:bytesize]) if options[:c]
  word_counts << " #{word_count_map[:path]}" unless word_count_map[:path].empty?
  puts word_counts.join
end

def format_word_count(word_count)
  word_count.to_s.rjust(8)
end

def display_word_count_from_files(paths, options)
  word_count_maps = build_word_count_maps(paths)
  word_count_maps.map { |word_count_map| display_word_count(word_count_map, options) }
  display_total_word_count(word_count_maps, options) if paths.size >= 2
end

def build_word_count_maps(paths)
  paths.map do |path|
    lines = File.readlines(path)
    build_word_count_map(lines, path)
  end
end

def display_total_word_count(word_count_maps, options)
  total_word_count_map = build_total_word_count_map(word_count_maps)
  display_word_count(total_word_count_map, options)
end

def build_total_word_count_map(word_count_maps)
  {
    number_of_lines: word_count_maps.sum { |word_count_map| word_count_map[:number_of_lines] },
    number_of_words: word_count_maps.sum { |word_count_map| word_count_map[:number_of_words] },
    bytesize: word_count_maps.sum { |word_count_map| word_count_map[:bytesize] },
    path: 'total'
  }
end

exec
