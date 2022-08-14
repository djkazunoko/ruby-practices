#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  options = parse_options
  options = { c: true, l: true, w: true } if options.empty?
  paths = ARGV
  paths.empty? ? wc_stdin(options) : wc_files(options, paths)
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
  file_data = build_counts_map(lines)
  puts format_file_data(file_data, options).join
end

def build_counts_map(lines)
  {
    line_number: count_line_number(lines),
    word_number: count_word_number(lines),
    bytesize: count_bytesize(lines)
  }
end

def count_line_number(lines)
  lines.size
end

def count_word_number(lines)
  lines.sum { |line| line.split(/[ \t\n]+/).size }
end

def count_bytesize(lines)
  lines.sum(&:bytesize)
end

def format_file_data(file_data, options)
  formatted_file_data = []
  formatted_file_data << " #{file_data[:line_number].to_s.rjust(7)}" if options[:l]
  formatted_file_data << " #{file_data[:word_number].to_s.rjust(7)}" if options[:w]
  formatted_file_data << " #{file_data[:bytesize].to_s.rjust(7)}" if options[:c]
  formatted_file_data << " #{file_data[:path]}" if file_data.has_key?(:path)
  formatted_file_data
end

def wc_files(options, paths)
  files = get_files(paths)
  files_data = get_files_data(files)
  files_data.map { |file_data| puts format_file_data(file_data, options).join}
  wc_total(files_data, options) if paths.size >= 2
end

def get_files(paths)
  paths.map do |path|
    {
      lines: File.readlines(path),
      path: path
    }
  end
end

def get_files_data(files)
  files.map do |file|
    file_data = build_counts_map(file[:lines])
    file_data[:path] = file[:path]
    file_data
  end
end

def wc_total(files_data, options)
  total_file_data = build_total_counts_map(files_data)
  puts format_file_data(total_file_data, options).push(' total').join
end

def build_total_counts_map(files_data)
  {
    line_number: files_data.sum { |file_data| file_data[:line_number] },
    word_number: files_data.sum { |file_data| file_data[:word_number] },
    bytesize: files_data.sum { |file_data| file_data[:bytesize] }
  }
end

exec
