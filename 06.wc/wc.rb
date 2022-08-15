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
  word_count_list << " #{word_count_map[:number_of_lines].to_s.rjust(7)}" if options[:l]
  word_count_list << " #{word_count_map[:number_of_words].to_s.rjust(7)}" if options[:w]
  word_count_list << " #{word_count_map[:bytesize].to_s.rjust(7)}" if options[:c]
  word_count_list << " #{word_count_map[:path]}" if word_count_map.key?(:path)
  puts word_count_list.join
end

def display_word_count_from_files(options, paths)
  files = build_files(paths)
  files_data = build_files_data(files)
  files_data.map { |word_count_map| display_word_count(word_count_map, options) }
  count_total(files_data, options) if paths.size >= 2
end

def build_files(paths)
  paths.map do |path|
    {
      lines: File.readlines(path),
      path: path
    }
  end
end

def build_files_data(files)
  files.map do |file|
    word_count_map = build_word_count_map(file[:lines])
    word_count_map[:path] = file[:path]
    word_count_map
  end
end

def count_total(files_data, options)
  total_word_count_map = build_total_counts_map(files_data)
  display_word_count(total_word_count_map, options)
end

def build_total_counts_map(files_data)
  {
    number_of_lines: files_data.sum { |word_count_map| word_count_map[:number_of_lines] },
    number_of_words: files_data.sum { |word_count_map| word_count_map[:number_of_words] },
    bytesize: files_data.sum { |word_count_map| word_count_map[:bytesize] }
  }
end

exec
