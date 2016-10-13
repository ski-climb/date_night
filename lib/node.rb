class Node
  attr_accessor :left,
                :right
  attr_reader :score, 
              :title,
              :depth

  def initialize(score, title, depth:)
    @score = score
    @title = title
    @depth = depth
  end

  def as_hash
    { title => score }
  end


end
