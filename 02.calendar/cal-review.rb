require 'optparse'

params = ARGV.getopts("m:y:")

month = params["m"]
year = params["y"]

puts "#{month}月 #{year}"
