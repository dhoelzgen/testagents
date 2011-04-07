include Java

require 'lib/eis-0.3.jar'
require 'lib/eismassim-1.0.jar'

module MassimActions
  include_class Java::eis.iilang.Action
  include_class Java::eis.iilang.Identifier

  def self.goto_action(node_name)
    Action.new "goto", (Identifier.new node_name)
  end
  
  def self.recharge_action
    Action.new "recharge"
  end
  
end

module MassimHelpers

  def self.get_percepts(percepts)
    result = Array.new
    percepts.each do |percept_array|
      percept_array.each do |percept_ll|
        percept_ll.each do |percept|
          # Idea: take these results of form visibleEdge(vertex3,vertex6) to
          # eval directly to ruby classes, or even better, prolog facts
          result << "#{percept}"
        end
      end
    end
    return result
  rescue
    return []
  end
end