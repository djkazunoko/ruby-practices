#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  params = option_parse
  word_count(ARGV)
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

def word_count(argv)
  display_word_count(argv)
  display_total_count(argv) if argv.size >= 2
end

def display_word_count(argv)
  argv.each do |file|
    row_count = get_row_count(file).to_s
    word_count = get_word_count(file).to_s
    filesize = File.size(file).to_s
    puts " #{row_count.rjust(7)} #{word_count.rjust(7)} #{filesize.rjust(7)} #{file}"
  end
end

def get_row_count(file)
  File.open(file) { |f| f.readlines.size }
end

def get_word_count(file)
  File.open(file) { |f| f.each.map { |line| line.split(/[ \t\n]+/).size}.sum }
end

def display_total_count(argv)
  total_map = get_total_map(argv)
  puts " #{total_map[:row_count].rjust(7)} #{total_map[:word_count].rjust(7)} #{total_map[:filesize].rjust(7)} total"
end

def get_total_map(argv)
  {
    row_count: argv.map { |file| get_row_count(file) }.sum.to_s,
    word_count: argv.map { |file| get_word_count(file) }.sum.to_s,
    filesize: argv.map { |file| File.size(file) }.sum.to_s
  }
end

exec
