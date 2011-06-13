require 'agents/saboteur_agent'

class AggressiveSaboteurAgent < SaboteurAgent
  
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