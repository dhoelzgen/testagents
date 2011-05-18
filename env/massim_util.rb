include Java

require 'ext/modified-eis'

module MassimActions
  include_class Java::eis.iilang.Action
  include_class Java::eis.iilang.Identifier

  def self.goto(node_name)
    Action.new "goto", (Identifier.new node_name)
  end
  
  def self.recharge
    Action.new "recharge"
  end
  
  def self.survey
    Action.new "survey"
  end
  
  def self.probe
    Action.new "probe"
  end
  
  def self.attack(target_name)
    Action.new "attack", (Identifier.new target_name)
  end
  
  def self.inspect
    Action.new "inspect"
  end
  
  def self.repair(target_name)
    Action.new "repair", (Identifier.new target_name)
  end
  
  def self.skip
    Action.new "skip"
  end
end