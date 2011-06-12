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

# Redirect ruby output stream
class FakeStdOut; def write(*args); end; end;

@real_stdout = $stdout
@real_errout = $errout

$stdout = FakeStdOut.new
$errout = FakeStdOut.new

# Load batch config
config = YAML::load( File.open( 'batch/config.yaml' ) )

# Run batch

@batch_log = Array.new

def add_batch_log(msg)
  log = "#{Time.now} - #{msg}"
  @batch_log << log
  @real_stdout.puts log
end

config.each_with_index do |team_a, a_index|
  a_name, a_members = team_a
  
  config.each_with_index do |team_b, b_index|
    b_name, b_members = team_b
    next if b_index < a_index
    
    a_score = 0
    b_score = 0
    step = 0
    
    # Start Massim
    massim = Thread.new do
      log = `./massim.sh`
    end
  
    sleep 3
    sim_string = "Team #{a_name.to_s.capitalize} vs. Team #{b_name.to_s.capitalize}:".ljust(42)
    @real_stdout.puts "#{sim_string}"
  
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
  
    # Wait until simulation is finished
    while !massim.stop?
      sleep 10
      
      # Gather score
      a_score = team_a.agents.first.team_score
      b_score = team_b.agents.first.team_score
      step = team_a.agents.first.current_step
      @real_stdout.puts "Step #{step.to_s.center(3)}: #{a_score.to_s.center(7)} - #{b_score.to_s.center(7)}"
    end
  
    # Clean up
    team_a.stop
    team_b.stop
    environment.stop
    
    # TODO: Find a way to really clean up the java listener threads
    
    # Remember result
    add_batch_log "#{sim_string} #{a_score.to_s.center(7)} - #{b_score.to_s.center(7)}"
    
  end
end

# Print log
@real_stdout.puts "\n\n Results: \n\n"
@batch_log.each do |log|
  @real_stdout.puts log
end

