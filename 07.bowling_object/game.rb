require_relative 'frame'

class Game
  def initialize(frames)
    @frames = frames
  end

  def score
    @game_score = 0
    (0..9).each do |n|
      @frame = Frame.new(@frames[n])
      @game_score += @frame.score
      @frames[n + 1] ||= []
      @frames[n + 2] ||= []
      add_bonus_point(n)
    end
    @game_score
  end

  def add_bonus_point(n)
    if @frame.strike?
      next_two_shots = (@frames[n + 1] + @frames[n + 2]).slice(0, 2)
      bonus_point = next_two_shots.sum { |s| Shot.new(s).score }
      @game_score += bonus_point
    elsif @frame.spare?
      next_shot = @frames[n + 1][0]
      bonus_point = Shot.new(next_shot).score
      @game_score += bonus_point
    end
  end
end
