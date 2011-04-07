include Java

require 'lib/eis-0.3.jar'
require 'lib/eismassim-1.0.jar'

require 'massim_util'

class MassimAdapter
  include_class Java::eis.AgentListener
  include_class Java::eis.EILoader
  
  include Java::eis.AgentListener
  
  def initialize
    className = "massim.eismassim.EnvironmentInterface"
    @environment_interface = EILoader.fromClassName className
    puts "MassimAdapter initialized."
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def open(agent_name, connection_name)
    @environment_interface.registerAgent agent_name
    @environment_interface.associateEntity agent_name, connection_name
    @environment_interface.attachAgentListener agent_name, self
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def close(agent_name)
    @environment_interface.unregisterAgent agentName
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def handlePercept(agent_name, percept)
    puts "TODO: HANDLE PERCEPT FOR #{agent_name}: #{percept}"
  end
  
  def percepts(agent_name)
    @environment_interface.getAllPercepts agent_name
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def act!(agent_name, action)
    @environment_interface.performAction agent_name, action
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  
  def start
    @environment_interface.start
  rescue => ex
    puts "#{ex.class}: #{ex.message}"
  end
  

end
