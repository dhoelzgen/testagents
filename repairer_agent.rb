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
  
  on_goal :repair do
    say "Repairing #{bb.transient[:repair_target].name}"
    next skip! unless has_energy 2
    repair! bb.transient[:repair_target]
  end
  
  # TODO: "Random Walk" towards injured or disabled friends
  
end