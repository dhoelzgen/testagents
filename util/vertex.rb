class Vertex
  attr_accessor :name, :edges, :value
  attr_accessor :distance, :cost, :next_edge
  
  def initialize(name)
    @name = name
    @edges = Array.new
  end
  
  def probed?
    !value.nil?
  end
  
  def add_edge(target)
    if @edges.inject(true) { |mem, edge| next false if edge.target == target; mem }
      @edges << Edge.new( self, target )
    end
  end
  
  def random_edge(max_weight = INFINITY)
    candidates = @edges.find_all { |edge| edge.weight <= max_weight }
    return nil unless candidates.any?
    candidates[rand( @edges.size )]
  end
  
  def all_below(max_weight = INFINITY)
    @edges.find_all { |edge| edge.weight <= max_weight }
  end
  
  def [](vertex)
    @edges.each do |edge|
      return edge if edge.target == vertex
    end
    nil
  end
  
  def ==(other)
    return @name == other.name
  end
  
end