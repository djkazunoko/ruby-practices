require 'optparse'
require 'date'

params = ARGV.getopts("m:y:")
today = Date.today
params["m"] ||= today.month
params["y"] ||= today.year

month = params["m"]
year = params["y"]

puts "#{month}月 #{year}"
