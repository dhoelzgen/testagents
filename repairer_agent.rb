require 'simple_agent'

class RepairerAgent < SimpleAgent
  
  def setup
    super
    bb.role = "Repairer"
  end
  
  # Repair
  
  motivate :repair do
    next -1 unless bb.position
    
    # TODO: Check if destination vertex is known by agent
    candidates = @friends.values.find_all { |friend| friend.position == bb.position && friend.injured? && friend.name != @name }
    target = candidates.sort.first
    
    if bb.transient[:repair_target] = target
      100
    else
      -1
    end
  end

  motivate :findInjured do
    next -1 unless bb.position

    candidates = @friends.values.find_all { |friend| friend.injured? && friend.name != @name }
    next -1 unless candidates.any?

    # TODO: Handle unreachable agents
    # TODO: Check if destination vertex is known by agent
    # TODO: Target should be choosen by distance *and* health

    target = candidates.sort_by { |candidate| @graph[candidate.position].cost }.first
    
    next -1 if @graph[target.position].cost = INFINITY
    
    bb.transient[:injured_target] = target
    75
  end

  on_goal :findInjured do
    say "Walking to injured #{bb.transient[:injured_target].name}"
    edge = @graph[bb.transient[:injured_target]].next_edge

    # BUG: The following case should not happen, because the repair goal should have been selected
    next repair! bb.transient[:injured_target] if edge.nil?

    # The other agent will walk towards the repairer, so wait at current position
    next recharge! if edge.target.name == bb.transient[:injured_target].position

    next recharge! unless has_energy edge.weight
    goto! edge.target
  end
  
  on_goal :repair do
    # BUG: Sometimes bb.transient[:repair_target] is nil
    next recharge! if bb.transient[:repair_target].nil?
    
    say "Repairing #{bb.transient[:repair_target].name}"
    
    if bb.disabled
      next recharge! unless has_energy 3
    else
      next recharge! unless has_energy 2
    end
    
    repair! bb.transient[:repair_target]
  end
  
end