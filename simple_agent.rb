require 'active_agent'
require 'massim_util'

class SimpleAgent < ActiveAgent
  
  # Beliefsrevision (not really atm...)
  
  on_belief 'lastAction' do
    puts "Last Action: "
  end
  
  # Desire Generation
  
  motive 'recharge' do
    return 1
  end
  
  # Goal handling
  
  on_goal 'recharge' do
    puts "Decided to recharge: "
  end
  
end