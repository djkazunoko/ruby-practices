#!/usr/bin/env ruby
# frozen_string_literal: true

score = ARGV[0]
scores = score.split(',')
shots = []
scores.each do |s|
  if s == 'X'
    shots << 10
    shots << 0
  else
    shots << s.to_i
  end
end

frames = shots.each_slice(2).to_a

def strike?(frame)
  frame[0] == 10
end

def spare?(frame)
  frame.sum == 10
end

frames.each_with_index do |frame, idx|
  next_shot = frames[idx + 1][0]
  after_next_shot = next_shot == 10 ? frames[idx + 2][0] : frames[idx + 1][1]

  if strike?(frame)
    frames[idx][0] = frame[0] + next_shot + after_next_shot
  elsif spare?(frame)
    frames[idx][0] = frame[0] + next_shot
  end

  break if idx == 8
end

puts frames.flatten.sum
