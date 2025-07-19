require 'optparse'
require 'date'

params = ARGV.getopts("m:y:")
today = Date.today
params["m"] ||= today.month
params["y"] ||= today.year

month = params["m"].to_i
year = params["y"].to_i

puts "#{month}月 #{year}"
puts '日 月 火 水 木 金 土'

last_day = Date.new(year, month, -1).day

(1..last_day).each do |n|
  print n.to_s.rjust(2)
end
