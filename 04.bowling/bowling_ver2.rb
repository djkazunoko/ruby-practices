#!/usr/bin/env ruby
# frozen_string_literal: true

shots = ARGV[0].split(',').map { |s| s == 'X' ? 10 : s.to_i }

frame = []
frames = []
shots.each do |s|
  frame << s
  if frames.length < 10
    if frame.length >= 2 || s == 10
      frames << frame.dup
      frame.clear
    end
  else
    frames.last << s
  end
end

point = 0
(0..9).each do |n|
  point += frames[n].sum
  frames[n + 1] ||= []
  frames[n + 2] ||= []
  if frames[n][0] == 10
    point += (frames[n + 1] + frames[n + 2]).slice(0, 2).sum
  elsif frames[n].sum == 10
    point += frames[n + 1][0]
  end
end
puts point
