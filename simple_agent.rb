require 'massim_adapter'
require 'massim_util'

class SimpleAgent
  
  def initialize(agent_name)
    @agent_name = agent_name
    
    @adapter = MassimAdapter.new
    @adapter.open agent_name, agent_name
    @adapter.start
  end
  
  def run
    while true
      puts "Perception of a1: #{format_perceptions(@adapter.percepts "a1")}"
      # @adapter.act! "a1", MassimActions::goto_action("node1")
      sleep 5
    end
  end
  
  def format_perceptions(percepts)
    result = ""
    percepts.each do |percept_array|
      percept_array.each do |percept_ll|
        percept_ll.each do |percept|
          # Idea: take these results of form visibleEdge(vertex3,vertex6) to
          # eval directly to ruby classes, or even better, prolog facts
          result << "#{percept}"
        end
      end
    end
    result
  end
  
end