include Java

require 'lib/modified-eis'

module MassimActions
  include_class Java::eis.iilang.Action
  include_class Java::eis.iilang.Identifier

  def self.goto(node_name)
    Action.new "goto", (Identifier.new node_name)
  end
  
  def self.recharge
    Action.new "recharge"
  end
  
end