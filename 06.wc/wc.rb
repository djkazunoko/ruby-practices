#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  options = parse_options
  options = { c: true, l: true, w: true } if options.empty?
  paths = ARGV
  paths.empty? ? count_stdin(options) : count_files(options, paths)
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

def count_stdin(options)
  lines = $stdin.readlines
  file_data = build_counts_map(lines)
  puts format_file_data(file_data, options).join
end

def build_counts_map(lines)
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

def format_file_data(file_data, options)
  formatted_file_data = []
  formatted_file_data << " #{file_data[:number_of_lines].to_s.rjust(7)}" if options[:l]
  formatted_file_data << " #{file_data[:number_of_words].to_s.rjust(7)}" if options[:w]
  formatted_file_data << " #{file_data[:bytesize].to_s.rjust(7)}" if options[:c]
  formatted_file_data << " #{file_data[:path]}" if file_data.has_key?(:path)
  formatted_file_data
end

def count_files(options, paths)
  files = build_files(paths)
  files_data = build_files_data(files)
  files_data.map { |file_data| puts format_file_data(file_data, options).join}
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
    file_data = build_counts_map(file[:lines])
    file_data[:path] = file[:path]
    file_data
  end
end

def count_total(files_data, options)
  total_file_data = build_total_counts_map(files_data)
  puts format_file_data(total_file_data, options).push(' total').join
end

def build_total_counts_map(files_data)
  {
    number_of_lines: files_data.sum { |file_data| file_data[:number_of_lines] },
    number_of_words: files_data.sum { |file_data| file_data[:number_of_words] },
    bytesize: files_data.sum { |file_data| file_data[:bytesize] }
  }
end

exec
