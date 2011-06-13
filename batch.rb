include Java

require 'yaml'
require 'date'
require 'ftools'

require 'lib/team'

# Default agents

require 'agents/simple_agent'
require 'agents/explorer_agent'
require 'agents/saboteur_agent'
require 'agents/inspector_agent'
require 'agents/repairer_agent'
require 'agents/sentinel_agent'

# Experimental agents

require 'experimental/aggressive_saboteur'

# Environment

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
@logpath = "log/#{DateTime::now.strftime "%s"}"

File.makedirs(@logpath)
File.makedirs("#{@logpath}/data")

@batch_log = Array.new

def add_batch_log(msg)
  log = "#{Time.now} - #{msg}"
  @batch_log << log
  @real_stdout.puts log
  
  File.open("#{@logpath}/results.txt", 'a') do |logfile|
    logfile.write("#{log}\n")
  end
end

config.each_with_index do |team_a, a_index|
  a_name, a_members = team_a
  
  config.each_with_index do |team_b, b_index|
    b_name, b_members = team_b
    next if b_index < a_index
    
    a_score, a_zone_score = 0
    b_score, b_zone_score = 0
    
    data_a_score = Array.new
    data_b_score = Array.new
    data_a_zone = Array.new
    data_b_zone = Array.new
    
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
      data_a_score << (a_score = team_a.agents.first.team_score)
      data_b_score << (b_score = team_b.agents.first.team_score)
      data_a_zone << (a_zone_score = team_a.agents.first.zone_score)
      data_b_zone << (b_zone_score = team_b.agents.first.zone_score)
      
      step = team_a.agents.first.current_step
      @real_stdout.puts "Step #{step.to_s.center(3)}: #{a_score.to_s.center(7)} - #{b_score.to_s.center(7)} (#{a_zone_score.to_s.center(7)} - #{b_zone_score.to_s.center(7)})"
    end
  
    # Clean up
    team_a.stop
    team_b.stop
    environment.stop
    
    # TODO: Find a way to really clean up the java listener threads
    
    # Save data for chart creation
    chart_data = [data_a_score, data_a_zone, data_b_score, data_b_zone]
    sim_data = { :data => chart_data,
      :title => "#{a_name} vs. #{b_name}",
      :legend => ['A Score','A Zone', 'B Score', 'B Zone'],
      :bar_colors => 'ff0000,ff8888,0000ff,8888ff',
      :format => 'file', :filename => "charts/#{a_name}_vs_#{b_name}.png",
      :size => '600x400'
    }
    
    File.open("#{@logpath}/data/#{a_name}_vs_#{b_name}.yaml", 'w+') do |data|
      data.write(sim_data.to_yaml)
    end
    
    # Remember result
    add_batch_log "#{sim_string} #{a_score.to_s.center(7)} - #{b_score.to_s.center(7)} (#{a_zone_score.to_s.center(7)} - #{b_zone_score.to_s.center(7)})"
    
  end
end

# Print log
@real_stdout.puts "\n\n Results: \n\n"
@batch_log.each do |log|
  @real_stdout.puts log
end


