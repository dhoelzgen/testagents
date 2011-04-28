include Java

require 'lib/modified-eis'
require 'massim_util'
require 'pp'

class MassimAdapter
  include_class Java::eis.AgentListener
  include_class Java::eis.EILoader
  
  include Java::eis.AgentListener
  
  def initialize
    className = "massim.eismassim.EnvironmentInterface"
    @environment_interface = EILoader.fromClassName className
    @attached_agents = Hash.new
    @cached_percepts = Hash.new
    puts "MassimAdapter initialized."
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end
  
  def open(agent_name, connection_name, agent_thread)
    @environment_interface.registerAgent agent_name
    @environment_interface.associateEntity agent_name, connection_name
    @environment_interface.attachAgentListener agent_name, self
    
    @attached_agents[agent_name] = agent_thread
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end
  
  def close(agent_name)
    @environment_interface.unregisterAgent agentName
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end
  
  def handlePercept(agent_name, percept)
    raise "Wrong EIS notification mechanism called"
  end
  
  def handlePercepts(agent_name, percepts)
    @cached_percepts[agent_name] = percepts
    @attached_agents[agent_name].wakeup
  end
  
  def new_percepts(agent_name)
    @cached_percepts[agent_name] and @cached_percepts.delete agent_name
  end
  
  def percepts(agent_name)
    MassimHelpers::get_percepts @environment_interface.getAllPercepts( agent_name )
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end
  
  def act!(agent_name, action)
    @environment_interface.performAction agent_name, action
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end
  
  def start
    @environment_interface.start
  rescue => ex
    pp "#{ex.class}: #{ex.message}"
  end
  

end
