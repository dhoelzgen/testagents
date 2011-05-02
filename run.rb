include Java

require 'initialize'

require 'simple_agent'
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
agents << (SimpleAgent.new "a1", adapter)
agents << (SimpleAgent.new "a2", adapter)
agents << (SimpleAgent.new "a3", adapter)
agents << (SimpleAgent.new "a4", adapter)
agents << (SimpleAgent.new "a5", adapter)
agents << (SimpleAgent.new "a6", adapter)
agents << (SimpleAgent.new "a7", adapter)
agents << (SimpleAgent.new "a8", adapter)
agents << (SimpleAgent.new "a9", adapter)
agents << (SimpleAgent.new "a10", adapter)

adapter.start