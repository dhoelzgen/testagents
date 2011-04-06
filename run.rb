require 'simple_agent'

# Redirect java output stream
include_class 'java.io.PrintStream'
include_class 'java.io.ByteArrayOutputStream'
include_class 'java.lang.System'

# java_out_stream = ByteArrayOutputStream.new
# System.setOut(PrintStream.new(java_out_stream))

# Note - To change java output do this:
# puts my_output_stream.toString.gsub("Static", "Dynamic")

agents = Array.new
agents << (SimpleAgent.new "a1")
# agents << (SimpleAgent.new "a2")
# agents << (SimpleAgent.new "a3")

agents.each { |agent| agent.run}