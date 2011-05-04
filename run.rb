include Java

require 'initialize'

require 'simple_agent'
require 'explorer_agent'
require 'saboteur_agent'
require 'inspector_agent'
require 'repairer_agent'

require 'massim_adapter'

# Redirect java output stream
include_class 'java.io.PrintStream'
include_class 'java.io.ByteArrayOutputStream'
include_class 'java.lang.System'

java_out_stream = ByteArrayOutputStream.new
System.setOut(PrintStream.new(java_out_stream))

# Note - To change java output do this:
# puts my_output_stream.toString.gsub("Static", "Dynamic")

def message_to_all(source, msg)
  receivers = @@agents.find_all { |agent| agent.name != source }
  receivers.each { |receiver| receiver.add_message msg}
end

adapter = MassimAdapter.new

@@agents = Array.new
@@agents << (ExplorerAgent.new "a1", "A", adapter) # Explorer
@@agents << (ExplorerAgent.new "a2", "A", adapter)
@@agents << (RepairerAgent.new "a3", "A", adapter) # Repairer
@@agents << (RepairerAgent.new "a4", "A", adapter)
@@agents << (SaboteurAgent.new "a5", "A", adapter) # Saboteur
@@agents << (SaboteurAgent.new "a6", "A", adapter)
@@agents << (SimpleAgent.new "a7", "A", adapter) # Sentinel
@@agents << (SimpleAgent.new "a8", "A", adapter)
@@agents << (InspectorAgent.new "a9", "A", adapter) # Inspector
@@agents << (InspectorAgent.new "a10", "A", adapter)

if true
  @@agents << (ExplorerAgent.new "b1", "B", adapter) # Explorer
  @@agents << (ExplorerAgent.new "b2", "B", adapter)
  @@agents << (RepairerAgent.new "b3", "B", adapter) # Repairer
  @@agents << (RepairerAgent.new "b4", "B", adapter)
  @@agents << (SaboteurAgent.new "b5", "B", adapter) # Saboteur
  @@agents << (SaboteurAgent.new "b6", "B", adapter)
  @@agents << (SimpleAgent.new "b7", "B", adapter) # Sentinel
  @@agents << (SimpleAgent.new "b8", "B", adapter)
  @@agents << (InspectorAgent.new "b9", "B", adapter) # Inspector
  @@agents << (InspectorAgent.new "b10", "B", adapter)
end

adapter.start