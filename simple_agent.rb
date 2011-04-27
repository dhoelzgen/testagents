require 'massim_adapter'
require 'massim_util'

class SimpleAgent

  def initialize(agent_name, adapter)
    @agent_name = agent_name
    @adapter = adapter
    @adapter.open agent_name, agent_name
  end

  def run
    while true
      puts "Next step for #{@agent_name}."
      print_perceptions @adapter.percepts(@agent_name)
      @adapter.act! @agent_name, MassimActions::goto_action("node1") if @agent_name == "a1"
      @adapter.act! @agent_name, MassimActions::recharge_action if @agent_name == "a2"
      sleep 3
    end
  end

  def print_perceptions(percepts)
    result = ""
    MassimHelpers::get_percepts(percepts).each do |percept|
      # Idea: take these results of form visibleEdge(vertex3,vertex6) to
      # eval directly to ruby classes, or even better, prolog facts
      case percept
      when /lastAction\((.*)\)/
        puts "#{@agent_name}'s action: #$1"
      when /lastActionResult\((.*)\)/
        puts "#{@agent_name}'s result: #$1"
      else
        #
      end
    end
    result
  end

end