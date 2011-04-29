class Belief
  attr_accessor :belief, :context
  
  def initialize(belief, context)
    @belief = belief
    @context = context
  end
end