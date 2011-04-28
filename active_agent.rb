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
  
  def self.infer(*args, &block)
    puts "Infer method with args #{args}"
    block.call
  end
  
  def self.method_missing(sym, *args, &block)
    # puts "Magic symbol #{sym}(#{args})"
    return ( args.any? ? "#{sym}(#{args})" : "#{sym}" )
  end

end