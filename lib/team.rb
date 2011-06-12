class Team
  attr_reader :agents
  
  def initialize(environment, &block)
    @environment = environment
    @agents = Array.new
    block.call self if block
  end
  
  def agent(new_agent)
    new_agent.set_environment @environment, self
    @agents << new_agent
  end
  
  def message_to_all(source, msg)
    receivers = @agents.find_all { |agent| agent.name != source }
    receivers.each { |receiver| receiver.add_message msg}
  end
  
  def stop
    @agents.each do |agent|
      agent.kill!
      @environment.close agent.name
    end
  end
end