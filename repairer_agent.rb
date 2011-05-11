require 'simple_agent'

class RepairerAgent < SimpleAgent
  
  motivate :repair do
    candidates = @friends.values.find_all { |friend| friend.position == bb.position && friend.injured? && friend.name != @name }
    target = candidates.sort.first
    
    if bb.transient[:repair_target] = target
      80
    else
      -1
    end
  end
  
  motivate :findInjured do
    candidates = @friends.values.find_all { |friend| friend.injured? && friend.name != @name }
    next -1 unless candidates.any?
    
    # TODO: Handle unreachable agents
    target = candidates.sort_by { |candidate| @graph.distance :from => bb.position, :to => candidate.position }.first
    
    bb.transient[:injured_target] = target
    75
  end
  
  on_goal :repair do
    say "Repairing #{bb.transient[:repair_target].name}"
    
    if bb.disabled
      next recharge! unless has_energy 3
    else
      next recharge! unless has_energy 2
    end
    
    repair! bb.transient[:repair_target]
  end
  
  on_goal :findInjured do
    say "Walking to injured #{bb.transient[:injured_target].name}"
    edge = @graph.path :from => bb.position, :to => bb.transient[:injured_target].position
    
    next recharge! unless has_energy edge.weight
    goto! edge.target
  end
    
end