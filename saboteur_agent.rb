require 'simple_agent'

class SaboteurAgent < SimpleAgent
    
  motivate :attack do
    next -1 unless bb.position
    candidates = @enemies.values.find_all { |enemy| enemy.position == bb.position && enemy.enabled }
    target = candidates.sort.last
    
    if bb.transient[:attack_target] = target
      80
    else
      -1
    end
  end
  
  on_goal :attack do
    say "Attacking #{bb.transient[:attack_target].name}"
    next skip! unless has_energy 2
    attack! bb.transient[:attack_target]
  end
end