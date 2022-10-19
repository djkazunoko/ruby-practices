#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'game'

shots = ARGV[0].split(',')

frame = []
frames = []
shots.each do |s|
  frame << s
  if frames.length < 10
    if frame.length >= 2 || s == 'X'
      frames << frame.dup
      frame.clear
    end
  else
    frames.last << s
  end
end

game = Game.new(frames)
puts game.score
