class Edge
  attr_accessor :source, :target
  attr_writer :weight
  
  def initialize(source, target)
    @source = source
    @target = target
  end
  
  def weight
    return UNKNOWN_WEIGHT unless @weight
    @weight
  end
  
  def unknown_weight?
    return @weight.nil?
  end

end