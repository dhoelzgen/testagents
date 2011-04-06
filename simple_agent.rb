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
      # puts "Perception of a1: #{format_perceptions(@adapter.percepts "a1")}"
      # @adapter.act! "a1", MassimActions::goto_action("node1")
      sleep 5
    end
  end
  
  def format_perceptions(percepts)
    result = ""
    percepts.each do |percept|
      result << "#{percept.class}"
    end
  end
  
end