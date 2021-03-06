include Java
require 'date'
require 'ftools'

require 'lib/team'

require 'agents/simple_agent'
require 'agents/explorer_agent'
require 'agents/saboteur_agent'
require 'agents/inspector_agent'
require 'agents/repairer_agent'
require 'agents/sentinel_agent'

# Experimental agents

require 'experimental/aggressive_saboteur'
require 'experimental/parry_agents'

require 'env/massim'

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
  team.agent ParryExplorerAgent.new "b1", "B" # Explorer
  team.agent ParryExplorerAgent.new "b2", "B"
  team.agent ParryRepairerAgent.new "b3", "B" # Repairer
  team.agent ParryRepairerAgent.new "b4", "B"
  team.agent AggressiveSaboteurAgent.new "b5", "B" # Saboteur
  team.agent AggressiveSaboteurAgent.new "b6", "B"
  team.agent ParrySentinelAgent.new "b7", "B" # Sentinel
  team.agent ParrySentinelAgent.new "b8", "B"
  team.agent ParryInspectorAgent.new "b9", "B" # Inspector
  team.agent ParryInspectorAgent.new "b10", "B"
end

environment.start