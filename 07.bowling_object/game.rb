# frozen_string_literal: true

require_relative 'frame'

class Game
  def initialize(frames)
    @frames = frames
  end

  def score
    @game_score = 0
    (0..9).each do |idx|
      @frame = Frame.new(@frames[idx])
      @game_score += @frame.score
      @frames[idx + 1] ||= []
      @frames[idx + 2] ||= []
      @game_score += calc_bonus_point(idx)
    end
    @game_score
  end

  def calc_bonus_point(idx)
    if @frame.strike?
      next_two_shots = (@frames[idx + 1] + @frames[idx + 2]).slice(0, 2)
      bonus_point = next_two_shots.sum { |s| Shot.new(s).score }
    elsif @frame.spare?
      next_shot = @frames[idx + 1][0]
      bonus_point = Shot.new(next_shot).score
    else
      bonus_point = 0
    end
  end
end
