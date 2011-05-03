require 'belief_base'
require 'motive'
require 'goal'

class ActiveAgent
  attr_accessor :name, :team
  
  attr_accessor :belief_base
  alias_method :bb, :belief_base
  
  @percept_blocks = Hash.new
  @motive_raw = Array.new
  @goal_ary = Array.new
  
  def self.percept_blocks; @percept_blocks; end
  def self.motive_raw; @motive_raw; end
  def self.goal_ary; @goal_ary; end
  
  def initialize(agent_name, team, adapter)
    @name = agent_name
    @team = team
    @adapter = adapter
    @belief_base = BeliefBase.new
    @motive_ary = self.class.motive_raw.dup
    
    setup if self.respond_to? :setup
    
    @adapter.open agent_name, agent_name, Thread.new { run }
  end
  
  def self.inherited(subclass)
    subclass.init_vars(@percept_blocks.dup, @motive_raw.dup, @goal_ary.dup)
  end
  
  def self.init_vars(percept_blocks, motive_raw, goal_ary)
    @percept_blocks = percept_blocks
    @motive_raw = motive_raw
    @goal_ary = goal_ary
  end
  
  def run
    while true
      sleep
      
      before_revision if self.respond_to? :before_revision
      revise @adapter.new_percepts( @name )
      after_revision if self.respond_to? :after_revision
      
      before_motivation if self.respond_to? :before_motivation
      motivate
      after_motivation if self.respond_to? :after_motivation
      
      before_deliberation if self.respond_to? :before_deliberation
      deliberate
      after_deliberation if self.respond_to? :after_deliberation
    end
  rescue => ex
    puts "#{ex.class} in agent cycle: #{ex.message}\n#{ex.backtrace.inspect}"
  end
  
  def revise(percepts={})
    return unless percepts.any? and self.class.percept_blocks.any?
    
    percepts.each do |percept_string|
      percept_string = percept_string.dup
      percept_ary = "#{percept_string}".scan(/[A-Za-z0-9]+/) 
      percept_name = percept_ary.slice!(0)
            
      applicable_blocks = self.class.percept_blocks.find_all { |name, block| name.to_s == percept_name }
      
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
    candidate_goals = self.class.goal_ary.find_all { |goal| goal.name == goal_name }
    
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
    @percept_blocks[percept] = block
  end
  
  def self.motivate(name, &block)
    @motive_raw << Motive.new(name, block)
  end
  
  def self.on_goal(name, args={}, &block)
    @goal_ary << Goal.new(name, args, block)
  end

end