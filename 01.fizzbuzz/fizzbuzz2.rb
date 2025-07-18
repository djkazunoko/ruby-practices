#!/usr/bin/env ruby

20.times do |i|
  if (i+1) % 15 == 0
    puts 'FizzBuzz'
  elsif (i+1) % 3 == 0
    puts 'Fizz'
  elsif (i+1) % 5 == 0
    puts 'Buzz'
  else
    puts i+1
  end
end
