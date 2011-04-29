require 'belief'
require 'goal'

class ActiveAgent
  attr_accessor :name
  
  def initialize(agent_name, adapter)
    @name = agent_name
    @adapter = adapter
    @adapter.open agent_name, agent_name, Thread.new { run }
  end
  
  def run
    while true
      revise @adapter.new_percepts( @name )
      deliberate
      sleep 
    end
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def revise(percepts={})
    return unless percepts.any?
  end
  
  def deliberate
    puts "Deliberation for #{@name}"
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def act!(action)
    @adapter.act! @name, action
  end
  
  # Put this into another form, see Eloquent Ruby, p. 345
  def self.on_belief(belief, *context, &block)
    @belief_blocks ||= Hash.new
    @belief_blocks[Belief.new(belief, context)] = block
  end
  
  def self.on_goal(goal, *context, &block)
    @goal_blocks ||= Hash.new
    @goal_blocks[Goal.new(goal, context)] = block
  end
  
  def self.motive(motive, &block)
    @motive_blocks ||= Hash.new
    @motive_blocks[motive] = block
  end

end