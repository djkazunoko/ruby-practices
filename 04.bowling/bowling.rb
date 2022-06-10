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

frames = []
shots.each_slice(2) do |s|
  frames << s
end

frames_point = []
frames.each_with_index do |frame, i|
  frames_point[i] = frame.sum
  if i < 9
    if frame[0] == 10
      frames_point[i] += frames[i + 1][0]
      frames_point[i] += if frames[i + 1][0] == 10
                           frames[i + 2][0]
                         else
                           frames[i + 1][1]
                         end
    elsif frame.sum == 10
      frames_point[i] += frames[i + 1][0]
    end
  end
  frames_point[i] += frames_point[i - 1] if i != 0
end
puts frames_point.last
