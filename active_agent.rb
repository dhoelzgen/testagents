require 'belief_base'
require 'motive'

class ActiveAgent
  attr_accessor :name
  
  attr_accessor :belief_base
  alias_method :bb, :belief_base
  
  @@percept_blocks = Hash.new
  @@motive_ary = Array.new
  
  def initialize(agent_name, adapter)
    @name = agent_name
    @adapter = adapter
    @adapter.open agent_name, agent_name, Thread.new { run }
    
    @belief_base = BeliefBase.new
  end
  
  def run
    while true
      revise @adapter.new_percepts( @name )
      motivate
      deliberate
      sleep 
    end
  rescue => ex
    puts "#{ex.class} in agent cycle: #{ex.message}"
  end
  
  def revise(percepts={})
    return unless percepts.any? and @@percept_blocks.any?
    
    percepts.each do |percept_string|
      percept_ary = "#{percept_string}".scan(/[A-Za-z0-9]+/) 
      percept_name = percept_ary.slice!(0)
            
      applicable_blocks = @@percept_blocks.find_all { |name, block| name == percept_name }
      
      next unless applicable_blocks.any?
      
      applicable_blocks.each do |name, block|
        instance_exec( *percept_ary, &block )
      end
    end
  end
  
  def motivate
    return unless @@motive_ary.any?
    
    @@motive_ary.each do |motive|
      associated_block = motive.block
      motive.intensity = instance_eval( &associated_block )
    end
    
    @@motive_ary.sort!
    
    @@motive_ary.each { |motive| puts motive.name }
  end
  
  def deliberate
    puts "Deliberation for #{@name}"
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def act!(action)
    @adapter.act! @name, action
  end
  
  def say(msg)
    puts "#{@name}: #{msg}"
  end
  
  # Put this into another form, see Eloquent Ruby, p. 345
  def self.on_percept(percept,  &block)
    @@percept_blocks[percept] = block
  end
  
  def self.motivate(name, &block)
    @@motive_ary << Motive.new(name, block)
  end


end