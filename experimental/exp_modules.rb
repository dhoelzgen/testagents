module AggressiveTarget
  def random_target
    
    candidates = @enemies.values.find_all { |enemy| @graph[enemy.position].cost < 30 && enemy.enabled }
    
    candidates.sort! { |x, y| @graph[x.position].cost <=> @graph[y.position].cost }
    
    if candidates.first
      say "On my way to #{@graph[candidates.first.position].name} to attack #{candidates.first.name}"
      @graph[candidates.first.position].next_edge
    else
      nil
    end
  rescue => ex
    # TODO: It seems even if an exception is raised, nothing happens...
    error "#{ex.class} in random target for saboteur: #{ex.message}\n#{ex.backtrace.inspect}."
    nil
  end
end

module ParryComponents
  
  ENERGY_THRESHOLD = 5
  PARRY_INTENSITY = 100 # 100 = more than repair motive
 
  def self.included(base)  
    
    base.motivate :parry do
      next -1 unless bb.position and bb.energy and bb.maxEnergy
      next -1 if bb.disabled
      
      enemy_saboteurs = @enemies.values.find_all { |enemy| (enemy.position == bb.position) && enemy.role == "Saboteur" }
      next PARRY_INTENSITY if enemy_saboteurs.any?
      
      -1
    end
  
    base.on_goal :parry do
      if bb.energy >= ENERGY_THRESHOLD
        error "Parrying potential attack"
        next parry! 
      end
      
      if target = @graph[bb.position].random_edge( bb.energy )
        error "Fleeing to #{target.name}"
        next goto! target
      elsif bb.energy > 1
        error "Parrying potential attack"
        next parry!
      else
        error "No energy to flee or parry, recharging first"
        next recharge!
      end
    end
  end
  
  def enemy_at_spot
    
  end
  
end