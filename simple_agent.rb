require 'active_agent'
require 'massim_util'

class SimpleAgent < ActiveAgent
  
  def setup
    puts "Init SimpleAgent"
    @vertices = Hash.new
  end
  
  on_percept :lastAction do |action|
    bb.lastAction = action
    say "Last Action: #{bb.lastAction}"
  end
  
  on_percept :lastActionResult do |result|
    bb.lastActionResult = result
    say "Last Action Result: #{bb.lastActionResult}"
  end
  
  on_percept :health do |value|
    bb.health = value
    bb.disabled = ( bb.health == 0 ? true : false )
  end
  
  on_percept :energy do |value|
    bb.enery = value
  end
  
  on_percept :maxEnergy do |value|
    bb.maxEnergy = value
  end
  
  # Motives
  
  motivate :recharge do
    next 0 unless bb.energy
    next 30 if bb.energy < 3
    next 10 if bb.energy < bb.maxEnergy
    1
  end
  
  motivate :randomWalk do
    11
  end
  
  # Plans
  
  on_goal :randomWalk do
    act! MassimActions::goto("node1")
  end
  
  on_goal :recharge do
    act! MassimActions::recharge
  end
  
end