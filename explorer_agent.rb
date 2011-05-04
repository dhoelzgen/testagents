require 'simple_agent'

class ExplorerAgent < SimpleAgent
  
  motivate :probe do
    next -1 if bb.disabled
    next -1 unless current_node = @graph[bb.position]
    
    current_node.value.nil? ? 80 : 0
  end
  
  on_goal :probe do
    next skip! unless has_energy 1
    probe!
  end
  
  # TODO: "Random Walk" towards unprobed nodes
  
end