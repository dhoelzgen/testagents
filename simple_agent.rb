require 'active_agent'
require 'massim_util'

class SimpleAgent < ActiveAgent
  
  infer lastAction do
    puts "Inner block called"
  end
  
  infer lastAction(test_argument) do
    puts "Inner block called"
  end
  
end