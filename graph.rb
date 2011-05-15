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
    
    caldulate_path( from, to )[1]
  end
  
  def distance(args={})
    raise "Missing origin" unless from = @vertices[args[:from]]
    raise "Missing destination" unless to = @vertices[args[:to]]
    
    caldulate_path( from, to )[0]
  end
  
  def node_distance(args={})
    raise "Missing origin" unless from = @vertices[args[:from]]
    raise "Missing destination" unless to = @vertices[args[:to]]
    
    caldulate_path( from, to )[2]
  end
  
  protected
    
    def caldulate_path(position, to, visited=nil)
      return [0, nil, 0] if position == to
      visited ||= Array.new
      
      distance = INFINITY
      edge = false
      depth = 0
      
      position.edges.each do |e|
        next if visited.include? e.target
        next if e.weight > @max_energy
        
        c_dist, c_edge, c_depth = caldulate_path( e.target, to, ( visited.dup << e.target ) )
        
        if distance > c_dist then
          distance = c_dist + e.weight
          edge = e
          depth = c_depth
        end
      end
      
      return [distance, edge, depth +1]
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
  attr_accessor :name, :edges, :value
  
  def initialize(name)
    @name = name
    @edges = Array.new
  end
  
  def add_edge(target)
    if @edges.inject(true) { |mem, edge| next false if edge.target == target; mem }
      @edges << Edge.new( self, target )
    end
  end
  
  def random_edge(max_weight = INFINITY)
    candidates = @edges.find_all { |edge| edge.weight <= max_weight }
    candidates[rand( @edges.size )]
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