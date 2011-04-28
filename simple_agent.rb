require 'massim_adapter'
require 'massim_util'
require 'thread'
require "pp"

class SimpleAgent
  attr_accessor :name
  
  def initialize(agent_name, adapter)
    @name = agent_name
    @adapter = adapter
    @adapter.open agent_name, agent_name, Thread.new { run }
  end
  
  def run
    while true
      puts "Main Thread: #{@name}"
      deliberate @adapter.new_percepts( @name )
      sleep 
    end
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end
  
  def deliberate(percepts={})
    puts "Deliberation for #{@name} (#{percepts.count} percepts)"
    
    # Test percepts
    percepts.each do |percept|
      # puts " - #{percept}"
    end
    
    puts print_perceptions percepts unless percepts.empty?
    
    sleep 1 if @name == "a3"
    
    # Test actions
    @adapter.act! @name, MassimActions::goto_action("node1") if @name == "a1"
    @adapter.act! @name, MassimActions::recharge_action if @name == "a2"
    
    # Test cycle
    deliberate if (@name == "a3" && percepts.any?)
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end

  def print_perceptions(percepts)
    result = ""
    percepts.each do |percept|
      # Idea: take these results of form visibleEdge(vertex3,vertex6) to
      # eval directly to ruby classes, or even better, prolog facts
      case "#{percept}"
      when /lastAction\((.*)\)/
        puts "#{@name}'s action: #$1"
      when /lastActionResult\((.*)\)/
        puts "#{@name}'s result: #$1"
      else
        #
      end
    end
    result
  end

end