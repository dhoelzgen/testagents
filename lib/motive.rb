class Motive
  attr_accessor :name, :block, :intensity
  
  def initialize(name, block)
    @name = name
    @block = block
    @intensity = 0
  end
  
  def <=>(other)
    return unless other.is_a? Motive
    @intensity <=> other.intensity
  end
end