require 'util/vertex'
require 'util/edge'

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
  
  def floodfill(position)
    railse "Could not find position #{position}" unless start = @vertices[position]
    
    @vertices.values.each do |vertex|
      vertex.distance = INFINITY
      vertex.cost = INFINITY
      vertex.next_edge = false
    end
    
    start.distance = 0
    start.next_edge = nil
    
    start.edges.each do |edge|
      fill_path_values(edge, edge.target, edge.weight, 1, [start])
    end
  end
  
  def fill_path_values(next_edge, vertex, cost, distance, visited)
    if vertex.cost > cost
      vertex.cost = cost
      vertex.next_edge = next_edge
      vertex.distance = distance
      
      candidates = vertex.edges.find_all { |edge| !visited.include? edge.target }
      candidates.each do |edge|
        fill_path_values(next_edge, edge.target, cost + edge.weight, distance + 1, visited.dup << vertex)
      end
    end
  end
    
end