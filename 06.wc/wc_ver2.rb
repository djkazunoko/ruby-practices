#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  options = parse_options
  options = { c: true, l: true, w: true } if options.empty?
  paths = ARGV
  counts = build_counts(paths: paths)
  counts.map { |count| display_count(count: count, options: options) }
  display_total_count(counts: counts, options: options) if paths.size >= 2
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

def build_counts(paths:)
  if paths.empty?
    [build_count(text: $stdin.read)]
  else
    paths.map do |path|
      build_count(text: File.read(path), path: path)
    end
  end
end

def build_count(text:, path: '')
  {
    line_count: text.count("\n"),
    word_count: text.split(/\s+/).size,
    bytesize: text.bytesize,
    path: path
  }
end

def display_count(count:, options:)
  formatted_counts = []
  formatted_counts << format_count(count: count[:line_count]) if options[:l]
  formatted_counts << format_count(count: count[:word_count]) if options[:w]
  formatted_counts << format_count(count: count[:bytesize]) if options[:c]
  formatted_counts << " #{count[:path]}" unless count[:path].empty?
  puts formatted_counts.join
end

def format_count(count:)
  count.to_s.rjust(8)
end

def display_total_count(counts:, options:)
  total_count = build_total_count(counts: counts)
  display_count(count: total_count, options: options)
end

def build_total_count(counts:)
  {
    line_count: counts.sum { |count| count[:line_count] },
    word_count: counts.sum { |count| count[:word_count] },
    bytesize: counts.sum { |count| count[:bytesize] },
    path: 'total'
  }
end

exec
