require 'simple_agent'

class InspectorAgent < SimpleAgent
  
  def setup
    super
    bb.role = "Inspector"
  end
  
  motivate :inspect do
    next -1 if bb.disabled
    next -1 unless bb.position
    candidates = @enemies.values.find_all { |enemy| enemy.position == bb.position && !enemy.inspected? }
          
    if candidates.count > 0
      80
    else
      -1
    end
  end

  on_goal :inspect do
    say "Inspecting..."
    next recharge! unless has_energy 2
    inspect!
  end
  
  # TODO: "Random Walk" towards uninspected entities (low priority)
  
end