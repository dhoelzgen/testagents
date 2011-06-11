require 'agents/simple_agent'

class SaboteurAgent < SimpleAgent
  
  def setup
    super
    bb.role = "Saboteur"
  end
  
  motivate :attack do
    next -1 if bb.disabled
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
    # BUG: Sometimes bb.transient[:attack_target] is nil
    next recharge! if bb.transient[:attack_target].nil?
    
    say "Attacking #{bb.transient[:attack_target].name}"
    next recharge! unless has_energy 2
    attack! bb.transient[:attack_target]
  end
  
end