require 'active_agent'
require 'massim_util'

class SimpleAgent < ActiveAgent
  
  on_percept('lastAction') do |action|
    bb.last_action = action
    say "Last Action: #{bb.last_action}"
  end
  
  motivate 'recharge' do
    10
  end
  
  on_goal 'recharge' do
    act! MassimActions::recharge_action
  end
  
end