require_relative 'shot'

class Frame
  def initialize(frame)
    @first_shot = Shot.new(frame[0])
    @second_shot = Shot.new(frame[1])
    @third_shot = Shot.new(frame[2])
  end

  def score
    [
      @first_shot.score,
      @second_shot.score,
      @third_shot.score
    ].sum
  end
end
