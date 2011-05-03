require 'simple_agent'
require 'enemy'

class InspectorAgent < SimpleAgent
    
    on_percept :inspectedEntity do |name, team, role, position, energy, max_energy, health, max_health, strength, vis_range|
      say "Inspected agent #{name}, E #{energy} / #{max_energy}, H #{health} / #{max_health}"
      @enemies[name].set_inspected(role, max_energy, max_health)
    end
    
    motivate :inspect do
      next -1 unless bb.position
      candidates = @enemies.values.find_all { |enemy| enemy.position == bb.position && !enemy.inspected? }
      target = candidates.sort.last
      
      if bb.transient[:inspect_target] = target
        80
      else
        -1
      end
    end

    on_goal :inspect do
      say "Inspecting #{bb.transient[:inspect_target].name}"
      next unless has_energy 2
      inspect! bb.transient[:inspect_target]
    end
  
end