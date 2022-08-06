#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  params = option_parse
  count_file(ARGV)
  count_total(ARGV) if ARGV.size >= 2
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

def count_file(argv)
  counts = argv.map { |file| build_counts(file) }
  counts.each { |count| print_count(count) }
end

def build_counts(file)
  {
    line: line_counts(file).to_s,
    word: word_counts(file).to_s,
    byte: File.size(file).to_s,
    path: file
  }
end

def line_counts(file)
  File.open(file) { |f| f.readlines.size }
end

def word_counts(file)
  File.open(file) { |f| f.each.map { |line| line.split(/[ \t\n]+/).size}.sum }
end

def print_count(count)
  print [
    " #{count[:line].rjust(7)}",
    " #{count[:word].rjust(7)}",
    " #{count[:byte].rjust(7)}",
    " #{count[:path]}\n"
  ].join
end

def count_total(argv)
  total_counts = build_total_counts(argv)
  puts " #{total_counts[:line].rjust(7)} #{total_counts[:word].rjust(7)} #{total_counts[:byte].rjust(7)} total"
end

def build_total_counts(argv)
  {
    line: argv.map { |file| line_counts(file) }.sum.to_s,
    word: argv.map { |file| word_counts(file) }.sum.to_s,
    byte: argv.map { |file| File.size(file) }.sum.to_s
  }
end

exec
