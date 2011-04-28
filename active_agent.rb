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
  
  def self.method_missing(sym, *args, &block)
    unless /infer.*/ === sym.to_s # Should check against 
      puts "Magic Symbol #{sym}"
      return sym
    end
    puts "Magic Method #{sym} with args #{args}"
    block.call
  end

end