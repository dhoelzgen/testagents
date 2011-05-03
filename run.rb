include Java

require 'initialize'

require 'simple_agent'
require 'explorer_agent'
require 'saboteur_agent'

require 'massim_adapter'

# Redirect java output stream
include_class 'java.io.PrintStream'
include_class 'java.io.ByteArrayOutputStream'
include_class 'java.lang.System'

java_out_stream = ByteArrayOutputStream.new
System.setOut(PrintStream.new(java_out_stream))

# Note - To change java output do this:
# puts my_output_stream.toString.gsub("Static", "Dynamic")

adapter = MassimAdapter.new

agents = Array.new
agents << (ExplorerAgent.new "a1", "A", adapter) # Explorer
agents << (ExplorerAgent.new "a2", "A", adapter)
agents << (SimpleAgent.new "a3", "A", adapter) # Repairer
agents << (SimpleAgent.new "a4", "A", adapter)
agents << (SaboteurAgent.new "a5", "A", adapter) # Saboteur
agents << (SaboteurAgent.new "a6", "A", adapter)
agents << (SimpleAgent.new "a7", "A", adapter) # Sentinel
agents << (SimpleAgent.new "a8", "A", adapter)
agents << (SimpleAgent.new "a9", "A", adapter) # Inspector
agents << (SimpleAgent.new "a10", "A", adapter)

adapter.start