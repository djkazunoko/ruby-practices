# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(shots)
    @shots = shots
  end

  def score
    @frames = build_frames
    game_score = 0
    (0..9).each do |idx|
      frame = Frame.new(@frames[idx])
      game_score += frame.score
      @frames[idx + 1] ||= []
      @frames[idx + 2] ||= []
      game_score += calc_bonus_point(idx, frame)
    end
    game_score
  end

  def build_frames
    frame = []
    frames = []
    @shots.each do |s|
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
    frames
  end

  def calc_bonus_point(idx, frame)
    if frame.strike?
      next_two_shots = (@frames[idx + 1] + @frames[idx + 2]).slice(0, 2)
      bonus_point = next_two_shots.sum { |s| Shot.new(s).score }
    elsif frame.spare?
      next_shot = @frames[idx + 1][0]
      bonus_point = Shot.new(next_shot).score
    else
      bonus_point = 0
    end
  end
end
