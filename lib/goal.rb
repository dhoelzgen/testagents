class Goal
  attr_accessor :name, :context, :block

  def initialize(name, context, block)
    @name = name
    @context = context
    @block = block
  end
  
end