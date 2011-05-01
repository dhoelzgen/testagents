require 'active_agent'
require 'massim_util'

class SimpleAgent < ActiveAgent
  
  on_percept :lastAction do |action|
    bb.lastAction = action
    say "Last Action: #{bb.lastAction}"
  end
  
  motivate :recharge do
    10
  end
  
  on_goal :recharge, :lastAction => "recharge" do
    act! MassimActions::recharge_action
  end
  
  on_goal :recharge do
    act! MassimActions::recharge_action
  end
  
end