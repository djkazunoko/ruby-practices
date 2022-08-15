#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  options = parse_options
  options = { c: true, l: true, w: true } if options.empty?
  paths = ARGV
  paths.empty? ? display_word_count_from_stdin(options) : display_word_count_from_files(options, paths)
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

def build_word_count_map(lines)
  {
    number_of_lines: count_line(lines),
    number_of_words: count_word(lines),
    bytesize: count_bytesize(lines)
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
  word_count_list = []
  word_count_list << format_word_count(word_count_map[:number_of_lines]) if options[:l]
  word_count_list << format_word_count(word_count_map[:number_of_words]) if options[:w]
  word_count_list << format_word_count(word_count_map[:bytesize]) if options[:c]
  word_count_list << " #{word_count_map[:path]}" if word_count_map.key?(:path)
  puts word_count_list.join
end

def format_word_count(word_count)
  word_count.to_s.rjust(8)
end

def display_word_count_from_files(options, paths)
  word_count_map_list = build_word_count_map_list(paths)
  word_count_map_list.map { |word_count_map| display_word_count(word_count_map, options) }
  display_total_word_count(word_count_map_list, options) if paths.size >= 2
end

def build_word_count_map_list(paths)
  paths.map do |path|
    lines = File.readlines(path)
    word_count_map = build_word_count_map(lines)
    word_count_map[:path] = path
    word_count_map
  end
end

def display_total_word_count(word_count_map_list, options)
  total_word_count_map = build_total_word_count_map(word_count_map_list)
  display_word_count(total_word_count_map, options)
end

def build_total_word_count_map(word_count_map_list)
  {
    number_of_lines: word_count_map_list.sum { |word_count_map| word_count_map[:number_of_lines] },
    number_of_words: word_count_map_list.sum { |word_count_map| word_count_map[:number_of_words] },
    bytesize: word_count_map_list.sum { |word_count_map| word_count_map[:bytesize] },
    path: 'total'
  }
end

exec
