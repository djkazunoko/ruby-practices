require_relative 'frame'

class Game
  def initialize(frames)
    @frames = frames
  end

  def score
    @frames.sum { |f| Frame.new(f).score }
  end
end
