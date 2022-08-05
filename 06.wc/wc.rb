#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'

def exec
  params = option_parse
  row_count = get_row_count(ARGV[0]).to_s
  word_count = get_word_count(ARGV[0]).to_s
  filesize = File.size(ARGV[0]).to_s
  print " #{row_count.rjust(7)} #{word_count.rjust(7)} #{filesize.rjust(7)} #{ARGV[0]}"
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

def get_row_count(file)
  File.open(file) { |f| f.readlines.size }
end

def get_word_count(file)
  File.open(file) { |f| f.each.map { |line| line.split(/[ \t\n]+/).size}.sum }
end

exec
