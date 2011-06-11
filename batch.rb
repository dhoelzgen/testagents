include Java

require 'yaml'
require 'lib/team'

require 'agents/simple_agent'
require 'agents/explorer_agent'
require 'agents/saboteur_agent'
require 'agents/inspector_agent'
require 'agents/repairer_agent'
require 'agents/sentinel_agent'

require 'env/massim'

# Redirect java output stream
include_class 'java.io.PrintStream'
include_class 'java.io.ByteArrayOutputStream'
include_class 'java.lang.System'

java_out_stream = ByteArrayOutputStream.new
System.setOut(PrintStream.new(java_out_stream))

# Load batch config
config = YAML::load( File.open( 'batch/config.yaml' ) )

# Testcode

config.each do |a_name, a_members|
  config.each do |b_name, b_members|
    
    # Init environment
    environment = MassimAdapter.new
    
    # Init team A
    team_a = Team.new environment do |team|
      a_members.each_with_index do |agent_class, index|
        team.agent Module.const_get(agent_class).new "a#{index+1}", "A"
      end
    end
    
    # Init team B
    team_b = Team.new environment do |team|
      b_members.each_with_index do |agent_class, index|
        team.agent Module.const_get(agent_class).new "b#{index+1}", "B"
      end
    end
    
    # Start simulation
    environment.start
  end
end
