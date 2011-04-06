include Java

require 'lib/eis-0.3.jar'
require 'lib/eismassim-1.0.jar'

module MassimActions
  include_class Java::eis.iilang.Action
  include_class Java::eis.iilang.Identifier
  
  def self.goto_action(node_name)
    Action.new "goto", (Identifier.new node_name)
  end
end