require 'lib/active_agent'

require 'env/massim_util'

require 'util/graph'
require 'util/enemy'
require 'util/friend'

class SimpleAgent < ActiveAgent
  
  def setup
    puts "Init SimpleAgent"
    @graph = Graph.new
    @friends = Hash.new
    @enemies = Hash.new
    
    @team_score = 0
    @current_step = 0
    @sum_zone_score = 0
  end
  
  def before_revision
    bb.next_cycle
  end
  
  def before_motivation
    next unless bb.position
    @graph.floodfill bb.position
  end
  
  on_percept :lastAction do |action|
    bb.lastAction = action
  end
  
  on_percept :lastActionResult do |result|
    bb.lastActionResult = result
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
    @graph.max_energy = value.to_i
  end
  
  on_percept :position do |position|
    bb.position = position
    
    if friend = @friends[@name]
      friend.position = position
    end
    
    broadcast "friendPosition(#{@name}, #{position}, #{bb.role})"
  end
  
  on_percept :friendPosition do |name, position, role|
    if friend = @friends[name]
      friend.position = position
      friend.role = role
    end
  end
  
  on_percept :visibleEdge do |vertex_a, vertex_b|
    # TODO: Add edge and broadcast only if this is a new information
    @graph.add_edge vertex_a, vertex_b
    broadcast
  end
  
  on_percept :probedVertex do |vertex, value|
    # TODO: Add edge and broadcast only if this is a new information
    @graph.probed_vertex vertex, value
    broadcast
  end
  
  on_percept :surveyedEdge do |from, to, value|
    # TODO: Add edge and broadcast only if this is a new information
    @graph.surveyed_edge from, to, value
    broadcast
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
    enemy = ( @enemies[name] ||= Enemy.new( name, position, team, (health == 0 ? "disabled" : "normal" ) ) )
    enemy.set_inspected( role, max_energy, max_health )
  end
  
  # Motives
  
  motivate :recharge do
    next -1 unless bb.energy and bb.maxEnergy
    next 30 if bb.energy < 3
    next ( (bb.maxEnergy - bb.energy) * 2 ) if bb.energy < bb.maxEnergy
    1
  end
  
  motivate :randomWalk do
    11
  end
  
  motivate :survey do
    next -1 if bb.disabled
    next -1 unless @graph[bb.position]
    if @graph[bb.position].edges.inject(false) { |mem, edge| edge.unknown_weight? ? true : false }
      next 90
    end
    next 0
  end
  
  motivate :getRepaired do
    # TODO: Evaluate what a Repairer Agent should do
    next 95 if bb.health == 0 # && !( self.is_a? RepairerAgent )
    -1
  end
  
  # Plans
  
  on_goal :randomWalk do
    # DONE: Tend to stay if this is a good position
    if bb.zoneScore 
      next recharge! if rand(bb.zoneScore) > 20
    end
    
    next recharge! unless @graph[bb.position]
    
    if self.respond_to?( :random_target ) && selected_by_role = random_target
      selected_edge = selected_by_role
    else
      
      # DONE: If all friends are more than 3 nodes away, walk towards them
      friends_by_distance = @friends.values.find_all {|friend| friend.name != @name && !friend.disabled? }.collect { |friend| [ friend.position, (friend.position.nil? ? 0 : @graph[friend.position].distance ) ] }
      friends_by_distance.sort! { |x, y| x.last <=> y.last }
      
      if friends_by_distance.any? && friends_by_distance.first.last > 2
        
        # TODO: Add propability to change edge
        selected_edge = @graph[friends_by_distance.first.first].next_edge
        
      else
        
        # DONE: Select only edges with weight lower than maxEnergy
        selected_edge = @graph[bb.position].random_edge bb.maxEnergy
        
        candidates = @graph[bb.position].all_below( bb.maxEnergy ).collect { |edge| [edge, 0] }

        candidates.each do |edge, score|
          
          # DONE: Tend to walk towards nodes without other friendly agents
          score += 1 if @friends.values.all? { |friend| friend.position != edge.target.name }
          
          edge.target.edges.each do |edge_2nd|

            # DONE: Tend to walk towards nodes next to other nodes controlled by the team
            score += 1 if @friends.values.any? { |friend| friend.position == edge_2nd.target.name }

            # DONE: Tend to walk towards nodes with many nodes without friendly agents near them
            score += 1 if @friends.values.all? { |friend| friend.position != edge_2nd.target.name }
            
          end
                    
        end

        # TODO: Tend to avoid nodes with enabled emeny attacker (let attackers do this)

        # TODO: Tend to walk towards nodes where both friendly and enemy agents are present (could be dangerous)

        # TODO: Tend to walk towards nodes with high value, if now friendly agent is present
        
        # TODO: Walk towards unknown regions (nodes with unsurveyed edges)
        
        candidates.sort! { |x, y| x.last <=> y.last }
        
        # DONE: Pick random candidate with high score
        candidate_index = -1
        while change? && candidates[candidate_index] do
          selected_edge = candidates[candidate_index].first
          candidate_index -= 1
        end
        
      end
      
    end
    
    next recharge! unless selected_edge
    
    say "Going to node #{selected_edge.target.name}"
    next recharge! unless has_energy selected_edge.weight
    
    goto! selected_edge.target
  end
  
  on_goal :getRepaired do
    repairer = @friends.values.find_all { |friend| friend.role == "Repairer" && friend.name != @name }
    selected = repairer.sort_by { |candidate| @graph[candidate.position].cost }.first
    
    next recharge! unless selected
    
    edge = @graph[selected.position].next_edge
    
    # TODO: If edge == false, no way was found - Do something else in this case
    next recharge! unless edge
    next recharge! unless has_energy edge.weight
    
    if @graph[selected.position].cost == INFINITY
      # TODO: Walk towards unknown regions (nodes with unsurveyed edges)
      error "I want to get repaired, but I don't know the way"
    end
    
    goto! edge.target
  end
  
  on_goal :recharge do
    recharge!
  end
  
  on_goal :survey do
    next recharge! unless has_energy 1
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
  
  def change?
    rand( 0 ) > 0.6
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
  
  def parry!
    act! MassimActions::parry
  end
  
  # Batch Support
  
  on_percept :score do |score|
    @team_score = score.to_i
  end
  
  on_percept :step do |step|
    @current_step = step.to_i
  end
  
  on_percept :zonesScore do |zscore|
    @sum_zone_score += zscore.to_i
  end
  
  def team_score
    @team_score
  end
  
  def zone_score
    @sum_zone_score
  end
  
  def current_step
    @current_step
  end
  
end