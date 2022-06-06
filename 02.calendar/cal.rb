#!/usr/bin/env ruby

require 'date'
require 'optparse'

today = Date.today
options = ARGV.getopts("", "m:#{today.month}", "y:#{today.year}")

if options["m"].to_i >= 1 && options["m"].to_i <= 12
  inputed_month = options["m"].to_i
else
  puts "cal: #{options["m"]} is neither a month number (1..12) nor a name"
  return
end

if options["y"].to_i >= 1 && options["y"].to_i <= 9999
  inputed_year = options["y"].to_i
else
  puts "cal: year `#{options["y"]}' not in range 1..9999"
  return
end

first_date = Date.new(inputed_year, inputed_month, 1)
last_date = Date.new(inputed_year, inputed_month, -1)
space = "   "

puts "      #{inputed_month}月 #{inputed_year}"
puts "日 月 火 水 木 金 土"

print space * first_date.wday

def color_reverse(text)
  "\e[30m\e[47m#{text}\e[0m"
end

(first_date..last_date).each do |full_date|
  day_of_week = full_date.wday
  print " " if full_date.day <= 9
  if full_date == today
    print color_reverse(full_date.day)
  else
    print "#{full_date.day}"
  end
  print " "
  puts "" if day_of_week == 6
end

puts ""

