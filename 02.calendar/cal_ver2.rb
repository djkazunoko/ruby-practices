#!/usr/bin/env ruby

require 'date'
require 'optparse'

params = ARGV.getopts('m:y:')
month = (params['m'] || Date.today.month).to_i
year = (params['y'] || Date.today.year).to_i

if month < 1 || month > 12
  puts "cal: #{params['m']} is neither a month number (1..12) nor a name"
  return
end

if year < 1 || year > 9999
  puts "cal: year `#{params['y']}' not in range 1..9999"
  return
end

start_of_month = Date.new(year, month, 1)
end_of_month = Date.new(year, month, -1)

puts "      #{month}月 #{year}"
puts "日 月 火 水 木 金 土"
print " " * 3 * start_of_month.wday
(start_of_month..end_of_month).each do |day|
  format = day == Date.today ? "\e[7m%2d\e[0m " : '%2d '
  printf format, day.day
  puts "\n" if day.wday == 6
end
puts "\n\n"
