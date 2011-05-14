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
  
  on_goal :repair do
    # BUG: Sometimes bb.transient[:repair_target] is nil
    next recharg! if bb.transient[:repair_target].nil?
    
    say "Repairing #{bb.transient[:repair_target].name}"
    
    if bb.disabled
      next recharge! unless has_energy 3
    else
      next recharge! unless has_energy 2
    end
    
    repair! bb.transient[:repair_target]
  end
  
end