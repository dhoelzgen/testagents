require 'active_agent'
require 'massim_util'
require 'graph'

class SimpleAgent < ActiveAgent
  
  def setup
    puts "Init SimpleAgent"
    @graph = Graph.new
    @enemies = Hash.new
  end
  
  def before_revision
    bb.next_cycle
  end
  
  on_percept :lastAction do |action|
    bb.lastAction = action
    broadcast
    say "Last Action: #{bb.lastAction}" if is_perception?
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
    @graph.add_edge vertex_a, vertex_b
  end
  
  on_percept :probedVertex do |vertex, value|
    @graph.probed_vertex vertex, value
  end
  
  on_percept :surveyedEdge do |from, to, value|
    @graph.surveyed_edge from, to, value
  end
  
  on_percept :visibleEntity do |name, position, team, status|
    # TODO: Should add agents to the graph (with timestamp, and remove old position)
    # TODO: Update this information by inspector
    next if team == @team
    
    if enemy = @enemies[name]
      enemy.position = position
      enemy.status = status
    else
      @enemies[name] = Enemy.new( name, position, team, status )
    end
  end
  
  on_percept :inspectedEntity do |name, team, role, position, energy, max_energy, health, max_health, strength, vis_range|
    say "Inspected agent #{name}, E #{energy} / #{max_energy}, H #{health} / #{max_health}"
    enemy = ( @enemies[name] ||= Enemy.new( name, position, team, (health == 0 ? "disabled" : "normal" ) ) )
    enemy.set_inspected( role, max_energy, max_health )
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
  
  motivate :survey do
    next -1 unless @graph[bb.position]
    if @graph[bb.position].edges.inject(false) { |mem, edge| edge.weight.nil? ? true : false }
      next 50
    end
    next 0
  end
  
  # Plans
  
  on_goal :randomWalk do
    # TODO: Tend to walk towards nodes without other agents friendly (near it)
    # TODO: Tend to walk towards nodes with high value
    # TODO: Tend to stay if this is a good position
    # TODO: Tend to avoid nodes with enabled emeny agents (let attackers do this)
    
    next unless @graph[bb.position]
    edge = @graph[bb.position].random_edge # TODO: Select only edges with weight lower than maxEnergy
    next unless edge
    
    say "Going to node #{edge.target.name}"
    next unless has_energy edge.weight
    
    goto! edge.target
  end
  
  on_goal :recharge do
    recharge!
  end
  
  on_goal :survey do
    next unless has_energy 1
    survey!
  end
  
  # Util
  
  def has_energy(value)
    return true unless value
    return true unless bb.energy

    if bb.energy < value
      say "Not enough energy, recharging first..."
      recharge!
      return false
    end
    
    true
  end
  
  # Actions
  
  def recharge!
    act! MassimActions::recharge
  end
  
  def goto!(vertex)
    act! MassimActions::goto(vertex.name)
  end
  
  def survey!
    act! MassimActions::survey
  end
  
  def probe!
    act! MassimActions::probe
  end
  
  def attack!(enemy)
    act! MassimActions::attack(enemy.name)
  end
  
  def inspect!
    act! MassimActions::inspect
  end
  
end