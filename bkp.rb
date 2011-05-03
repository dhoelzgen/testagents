require 'belief_base'
require 'motive'
require 'goal'

class ActiveAgent
  attr_accessor :name
  
  attr_accessor :belief_base
  alias_method :bb, :belief_base
  
  @@percept_blocks = Hash.new
  @@motive_raw = Array.new
  @@goal_ary = Array.new
  
  def initialize(agent_name, adapter)
    @name = agent_name
    @adapter = adapter
    @belief_base = BeliefBase.new
    @motive_ary = @@motive_raw.dup
    
    setup if self.respond_to? :setup
    
    @adapter.open agent_name, agent_name, Thread.new { run }
  end
  
  def self.inherited(subclass)
    subclass.instance_eval do
      percept_dup = @@percept_blocks.dup
      @@percept_blocks = 
      @@motive_raw = @@motive_raw.dup
      @@goal_ary = @@goal_ary.dup
            
      def initialize(agent_name, adapter)
        
        super
      end
    end
  end
  
  def run
    sleep if @belief_base.empty?
    while true
      revise @adapter.new_percepts( @name )
      motivate
      deliberate
      sleep 
    end
  rescue => ex
    puts "#{ex.class} in agent cycle: #{ex.message}\n#{ex.backtrace.inspect}"
  end
  
  def revise(percepts={})
    return unless percepts.any? and @@percept_blocks.any?
    
    percepts.each do |percept_string|
      percept_string = percept_string.dup
      percept_ary = "#{percept_string}".scan(/[A-Za-z0-9]+/) 
      percept_name = percept_ary.slice!(0)
            
      applicable_blocks = @@percept_blocks.find_all { |name, block| name.to_s == percept_name }
      
      next unless applicable_blocks.any?
      
      applicable_blocks.each do |name, block|
        instance_exec( *percept_ary, &block )
      end
    end
  end
    
  def motivate
    return unless @motive_ary.any?
    
    @motive_ary.each do |motive|
      associated_block = motive.block
      motive.intensity = instance_exec( &associated_block )
    end
    
    @motive_ary.sort!
  end
  
  def deliberate
    return unless @motive_ary.any?
    
    goal_name = @motive_ary.last.name
    candidate_goals = @@goal_ary.find_all { |goal| goal.name == goal_name }
    
    unless candidate_goals.any?
      say "No candidate goal for #{goal_name}"
      return
    end
        
    candidate_goals.delete_if do |goal|
      next false unless goal.context.any?
      
      goal.context.inject(true) do |rmem, arg|
        next false if ( @belief_base.send(arg.first) != arg.last )
        rmem
      end
    end
    
    unless candidate_goals.any?
      say "No applicable goal for #{goal_name}"
      return
    end
        
    say "Goal: #{candidate_goals.first.name} (#{@motive_ary.last.intensity})"
    instance_eval( &candidate_goals.first.block )
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
    @@motive_raw << Motive.new(name, block)
  end
  
  def self.on_goal(name, args={}, &block)
    @@goal_ary << Goal.new(name, args, block)
  end

end