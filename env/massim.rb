include Java

require 'ext/modified-eis'
require 'env/massim_util'

class MassimAdapter
  include_class Java::eis.AgentListener
  include_class Java::eis.EILoader
  
  include Java::eis.AgentListener
  
  def initialize
    @stop = false
    className = "massim.eismassim.EnvironmentInterface"
    @environment_interface = EILoader.fromClassName className
    @attached_agents = Hash.new
    @cached_percepts = Hash.new
    puts "MassimAdapter initialized."
  rescue => ex
    puts "(ADAPTER) #{ex.class}: #{ex.message}"
  end
  
  def open(agent_name, agent_thread)
    @environment_interface.registerAgent agent_name
    @environment_interface.associateEntity agent_name, agent_name
    @environment_interface.attachAgentListener agent_name, self
    
    @attached_agents[agent_name] = agent_thread
  rescue => ex
    puts "(ADAPTER) #{ex.class}: #{ex.message}"
  end
  
  def close(agent_name)
    @attached_agents[agent_name].kill
    @attached_agents.delete agent_name
    @environment_interface.detachAgentListener agent_name, self
    @environment_interface.freeEntity agent_name
    puts "Environment connection for #{agent_name} closed"
  rescue => ex
    puts "(ADAPTER) #{ex.class}: #{ex.message}"
  end
  
  def handlePercept(agent_name, percept)
    raise "Wrong EIS notification mechanism called"
  end
  
  def handlePercepts(agent_name, percepts)
    return if @stop
    
    @cached_percepts[agent_name] = percepts
    @attached_agents[agent_name].run
  end
  
  def new_percepts(agent_name)
    @cached_percepts[agent_name] ||= {}
    result = @cached_percepts[agent_name].dup
    @cached_percepts.delete agent_name
    result
  end
  
  def act!(agent_name, action)
    @environment_interface.performAction agent_name, action
  rescue => ex
    puts "(ADAPTER) #{ex.class}: #{ex.message}"
  end
  
  def start
    @environment_interface.start
  rescue => ex
    puts "(ADAPTER) #{ex.class}: #{ex.message}"
  end
  
  def stop
    @stop = true
    @environment_interface.kill
    puts "Killed environment interface"
  rescue => ex
    puts "(ADAPTER) #{ex.class}: #{ex.message}"
  end
  
  def all_agents
    @attached_agents
  end
  
end
