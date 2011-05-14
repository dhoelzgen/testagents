include Java

require 'initialize'

require 'team'
require 'simple_agent'
require 'explorer_agent'
require 'saboteur_agent'
require 'inspector_agent'
require 'repairer_agent'
require 'sentinel_agent'

require 'massim_adapter'

# Redirect java output stream
include_class 'java.io.PrintStream'
include_class 'java.io.ByteArrayOutputStream'
include_class 'java.lang.System'

java_out_stream = ByteArrayOutputStream.new
System.setOut(PrintStream.new(java_out_stream))

# Note - To change java output do this:
# puts my_output_stream.toString.gsub("Static", "Dynamic")

environment = MassimAdapter.new

team_a = Team.new environment do |team|
  team.agent ExplorerAgent.new "a1", "A" # Explorer
  team.agent ExplorerAgent.new "a2", "A"
  team.agent RepairerAgent.new "a3", "A" # Repairer
  team.agent RepairerAgent.new "a4", "A"
  team.agent SaboteurAgent.new "a5", "A" # Saboteur
  team.agent SaboteurAgent.new "a6", "A"
  team.agent SentinelAgent.new "a7", "A" # Sentinel
  team.agent SentinelAgent.new "a8", "A"
  team.agent InspectorAgent.new "a9", "A" # Inspector
  team.agent InspectorAgent.new "a10", "A"
end


team_b = Team.new environment do |team|
  team.agent ExplorerAgent.new "b1", "B" # Explorer
  team.agent ExplorerAgent.new "b2", "B"
  team.agent RepairerAgent.new "b3", "B" # Repairer
  team.agent RepairerAgent.new "b4", "B"
  team.agent SaboteurAgent.new "b5", "B" # Saboteur
  team.agent SaboteurAgent.new "b6", "B"
  team.agent SentinelAgent.new "b7", "B" # Sentinel
  team.agent SentinelAgent.new "b8", "B"
  team.agent InspectorAgent.new "b9", "B" # Inspector
  team.agent InspectorAgent.new "b10", "B"
end

environment.start