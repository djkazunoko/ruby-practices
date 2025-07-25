#!/usr/bin/env ruby

require 'optparse'
require 'date'

params = ARGV.getopts("m:y:")
today = Date.today
params["m"] ||= today.month
params["y"] ||= today.year

month = params["m"].to_i
year = params["y"].to_i
last_day = Date.new(year, month, -1).day
first_wday = Date.new(year, month, 1).wday

puts "      #{month}月 #{year}"
puts '日 月 火 水 木 金 土'
print '   ' * first_wday

(1..last_day).each do |n|
  day = Date.new(year, month, n) == today ? "\e[47m\e[30m#{n}\e[0m" : n.to_s
  print "#{day.rjust(2)} "
  if (n + first_wday) % 7 == 0
    puts "\n"
  end
end
