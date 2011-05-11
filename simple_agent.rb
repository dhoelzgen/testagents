require 'active_agent'
require 'massim_util'
require 'graph'
require 'enemy'
require 'friend'

class SimpleAgent < ActiveAgent
  
  def setup
    puts "Init SimpleAgent"
    @graph = Graph.new
    @friends = Hash.new
    @enemies = Hash.new
  end
  
  def before_revision
    bb.next_cycle
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
    bb.health = value.to_i
    bb.disabled = ( bb.health == 0 ? true : false )
    
    next unless bb.maxHealth
    
    if agent = @friends[@name]
      agent.health = value.to_i
      agent.max_health = bb.maxHealth
    else
      @friends[@name] = Friend.new( @name, value.to_i, bb.maxHealth )
    end
    
    broadcast "friendHealth(#{@name}, #{value}, #{bb.maxHealth})"
  end
  
  on_percept :friendHealth do |name, value, max_value|
    if agent = @friends[name]
      agent.health = value.to_i
      agent.max_health = max_value.to_i
    else
      @friends[name] = Friend.new( name, value.to_i, max_value.to_i )
    end
  end
  
  on_percept :zoneScore do |score|
    bb.zoneScore = score.to_i
  end
  
  on_percept :maxHealth do |value|
    bb.maxHealth = value.to_i
  end
  
  on_percept :energy do |value|
    bb.energy = value.to_i
  end
  
  on_percept :maxEnergy do |value|
    bb.maxEnergy = value.to_i
  end
  
  on_percept :position do |position|
    bb.position = position
    
    if friend = @friends[@name]
      friend.position = position
    end
    
    broadcast "friendPosition(#{@name}, #{position})"
  end
  
  on_percept :friendPosition do |name, position|
    if friend = @friends[name]
      friend.position = position
    end
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
    next if team == @team
    broadcast
    
    if enemy = @enemies[name]
      enemy.position = position
      enemy.status = status
    else
      @enemies[name] = Enemy.new( name, position, team, status )
    end
  end
  
  on_percept :inspectedEntity do |name, team, role, position, energy, max_energy, health, max_health, strength, vis_range|
    next if team == @team
    
    broadcast
    say "Inspected agent #{name}, E #{energy} / #{max_energy}, H #{health} / #{max_health}" if is_percept?
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
    # TODO: Intensity should depend on current zone score
    #       If score is high, then the agent should tend to stay at its current place
    11
  end
  
  motivate :survey do
    next -1 if bb.disabled
    next -1 unless @graph[bb.position]
    if @graph[bb.position].edges.inject(false) { |mem, edge| edge.weight.nil? ? true : false }
      next 50
    end
    next 0
  end
  
  motivate :getRepaired do
    # TODO: Evaluate what a Repairer Agent should do
    next 100 if bb.health == 0 && !( self.is_a? RepairerAgent )
    -1
  end
  
  # Plans
  
  on_goal :randomWalk do
    # TODO: Tend to walk towards nodes without other agents friendly (near it)
    # TODO: Tend to walk towards nodes with high value
    # TODO: Tend to stay if this is a good position
    # IN PROGRESS: Test for Team A
    if bb.zoneScore && @team == "A" 
      next skip! if rand(bb.zoneScore) > 25
    end
    
    # TODO: Tend to avoid nodes with enabled emeny agents (let attackers do this)
    
    next skip! unless @graph[bb.position]
    edge = @graph[bb.position].random_edge # TODO: Select only edges with weight lower than maxEnergy
    next skip! unless edge
    
    say "Going to node #{edge.target.name}"
    next recharge! unless has_energy edge.weight
    
    goto! edge.target
  end
  
  on_goal :getRepaired do
    # TODO: Move towards Repairer Agent
    recharge!
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
  
  def repair!(friend)
    act! MassimActions::repair(friend.name)
  end
  
  def skip!
    act! MassimActions::skip
  end
  
end