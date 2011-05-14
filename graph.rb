class Graph
  attr_reader :vertices
  attr_accessor :max_energy
  
  def initialize
    @vertices = Hash.new
    @max_energy = INFINITY
  end
  
  def add_edge(name_from, name_to)
    vertex_from = ( @vertices[name_from] ||= Vertex.new(name_from) )
    vertex_to = ( @vertices[name_to] ||= Vertex.new(name_to) )
    
    vertex_from.add_edge(vertex_to)
    vertex_to.add_edge(vertex_from)
    
    return vertex_from, vertex_to
  end
  
  def surveyed_edge(from, to, value)
    vertex_from, vertex_to = add_edge(from, to)
    
    vertex_from[vertex_to].weight = value.to_i
    vertex_to[vertex_from].weight = value.to_i
  end
  
  def probed_vertex(name, value)
    vertex = ( @vertices[name] ||= Vertex.new(name) )
    vertex.value= value.to_i
  end
  
  def [](name)
    @vertices[name]
  end
  
  # Pathfinding
  
  def path(args={})
    raise "Missing origin" unless from = @vertices[args[:from]]
    raise "Missing destination" unless to = @vertices[args[:to]]
    
    init_markers(from)
    path_search from, to
  end
  
  def distance(args={})
    raise "Missing origin" unless from = @vertices[args[:from]]
    raise "Missing destination" unless to = @vertices[args[:to]]
    
    init_markers(from)
    path_distance from, to
  end
  
  protected
    
    def init_markers(from)
      @vertices.values.each { |vertex| vertex.marked = (vertex == from ? true : false ) }
    end
    
    def path_search(position, to)
      position.mark!
      return nil if position == to
      position.edges.min_by do |e|
        next INFINITY if e.target.marked?
        next INFINITY if e.weight > @max_energy
        candidate = path_search(e.target, to)
        e.weight + ( candidate.nil? ? 0 : candidate.weight )
      end
    end
    
    def path_distance(position, to)
      position.mark!
      return 0 if position == to
      result = INFINITY
      position.edges.each do |e|
        next if e.target.marked?
        next if e.weight > @max_energy
        candidate = path_distance(e.target, to) + e.weight
        if result > candidate then
          result = candidate
        end
      end
      return result
    end
    
end

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

class Vertex
  attr_accessor :name, :edges, :value, :marked
  
  def initialize(name)
    @name = name
    @marked = false
    @edges = Array.new
  end
  
  def add_edge(target)
    if @edges.inject(true) { |mem, edge| next false if edge.target == target; mem }
      @edges << Edge.new( self, target )
    end
  end
  
  def mark!
    @marked = true
  end
  
  def marked?
    @marked
  end
  
  def random_edge
    @edges[rand( @edges.size )]
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