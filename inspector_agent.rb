require 'simple_agent'
require 'enemy'

class InspectorAgent < SimpleAgent
    
    motivate :inspect do
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
      next unless has_energy 2
      inspect!
    end
  
end