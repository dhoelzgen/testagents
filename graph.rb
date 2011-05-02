class Graph
  attr_reader :vertices
  
  def initialize
    @vertices = Hash.new
  end
  
  def add_edge(name_from, name_to)
    vertex_from = ( @vertices[name_from] ||= Vertex.new(name_from) )
    vertex_to = ( @vertices[name_to] ||= Vertex.new(name_to) )
    
    vertex_from.add_edge(vertex_to)
    vertex_to.add_edge(vertex_from)
  end
  
  def [](name)
    @vertices[name]
  end
end

class Edge
  attr_accessor :source, :target, :weight
  
  def initialize(source, target)
    @source = source
    @target = target
  end
end

class Vertex
  attr_accessor :name, :edges
  
  def initialize(name)
    @name = name
    @edges = Array.new
  end
  
  def add_edge(target)
    if @edges.inject(true) { |mem, edge| next false if edge.target == target; mem }
      @edges << Edge.new( self, target )
    end
  end
  
  def random_edge
    @edges[rand( @edges.size )]
  end
  
  
end