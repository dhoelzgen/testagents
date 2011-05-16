require 'simple_agent'

class ExplorerAgent < SimpleAgent
  
  def setup
    super
    bb.role = "Explorer"
  end
  
  motivate :probe do
    next -1 if bb.disabled
    next -1 unless current_node = @graph[bb.position]
    
    current_node.value.nil? ? 80 : 0
  end
  
  on_goal :probe do
    next recharge! unless has_energy 1
    probe!
  end
  
  # DONE: "Random Walk" towards unprobed nodes
  
  def random_target
    candidates = @graph.vertices.values.find_all { |vertex| !vertex.probed? && vertex.cost < 20 }
    
    # DONE: Only choose vertices where another agent of the team is present
    candidates = candidates.find_all do |vertex|
      @friends.values.any? { |friend| friend.position == vertex.name }
    end
    
    candidates.sort! { |x, y| x.cost <=> y.cost }
    
    if candidates.first
      say "On my way to #{candidates.first.name} to probe its value"
      candidates.first.next_edge
    else
      nil
    end
  rescue => ex
    # TODO: It seems even if an exception is raised, nothing happens...
    error "#{ex.class} in random target for explorer: #{ex.message}\n#{ex.backtrace.inspect}."
    nil
  end
  
end