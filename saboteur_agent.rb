require 'simple_agent'
require 'enemy'

class SaboteurAgent < SimpleAgent
  
  # visibleEntity(a2,vertex4,A,normal)
  on_percept :visibleEntity do |name, position, team, status|
    next if team == @team
    
    bb.transient[:attack] ||= Array.new
    bb.transient[:attack] << Enemy.new( name, position, team, status )
  end
  
  motivate :attack do
    next -1 unless candidates = bb.transient[:attack]
    
    candidates.sort!
    target = candidates.find do |candidate|
      ( candidate.position == bb.position &&  !candidate.disabled )
    end
    
    if bb.transient[:attack_target] = target
      80
    else
      -1
    end
  end
  
  on_goal :attack do
    say "Attacking #{bb.transient[:attack_target].name}"
    next unless has_energy 2
    attack! bb.transient[:attack_target]
  end
end