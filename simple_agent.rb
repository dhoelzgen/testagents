require 'active_agent'
require 'massim_util'
require 'graph'

class SimpleAgent < ActiveAgent
  
  def setup
    puts "Init SimpleAgent"
    @graph = Graph.new
  end
  
  on_percept :lastAction do |action|
    bb.lastAction = action
    say "Last Action: #{bb.lastAction}"
  end
  
  on_percept :lastActionResult do |result|
    bb.lastActionResult = result
    say "Last Action Result: #{bb.lastActionResult}"
  end
  
  on_percept :health do |value|
    bb.health = value
    bb.disabled = ( bb.health == 0 ? true : false )
  end
  
  on_percept :maxHealth do |value|
    bb.maxHealth = value
  end
  
  on_percept :energy do |value|
    bb.energy = value.to_i
  end
  
  on_percept :maxEnergy do |value|
    bb.maxEnergy = value.to_i
  end
  
  on_percept :position do |position|
    bb.position = position
  end
  
  on_percept :visibleEdge do |vertex_a, vertex_b|
    @graph.add_edge(vertex_a, vertex_b)
  end
  
  # Motives
  
  motivate :recharge do
    say "Energy: #{bb.energy} / #{bb.maxEnergy}"
    next 0 unless bb.energy and bb.maxEnergy
    next 30 if bb.energy < 3
    next ( (bb.maxEnergy - bb.energy) * 2 ) if bb.energy < bb.maxEnergy
    1
  end
  
  motivate :randomWalk do
    11
  end
  
  # Plans
  
  on_goal :randomWalk do
    edge = @graph[bb.position].random_edge # TODO: Select only edges with weight lower than maxEnergy
    next unless edge
    
    say "Going to node #{edge.target.name}"
    
    if edge.weight && edge.weight > edge.energy
      say "Not enough energy, recharging first..."
      recharge!
      next
    end
    
    goto! edge.target
  end
  
  on_goal :recharge do
    recharge!
  end
  
  # Actions
  
  def recharge!
    act! MassimActions::recharge
  end
  
  def goto!(vertex)
    act! MassimActions::goto(vertex.name)
  end
  
end