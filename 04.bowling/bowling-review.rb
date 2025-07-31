#!/usr/bin/env ruby
# frozen_string_literal: true

def parse_marks(marks)
  pins = marks.split(',').map { |m| m == 'X' ? 10 : m.to_i }

  frames = []
  frame = []
  pins.each do |p|
    frame << p

    if frames.length < 10
      if frame.length >= 2 || p == 10
        frames << frame.dup
        frame.clear
      end
    else
      frames.last << p
    end
  end

  frames
end

def score_for(frames)
  score = 0
  (0..9).each do |n|
    frame, next_frame, after_next_frame = frames.slice(n, 3)
    next_frame ||= []
    after_next_frame ||= []

    score += if frame[0] == 10 # strike
               frame.sum + (next_frame + after_next_frame).slice(0, 2).sum
             elsif frame.sum == 10 # spare
               frame.sum + next_frame[0]
             else
               frame.sum
             end
  end
  score
end

frames = parse_marks(ARGV[0])
puts score_for(frames)
