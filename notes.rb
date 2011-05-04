a1 = [edges(47), steps(1000), vertices(20), simStart, id(0), visibleEdge(vertex3,vertex6), visibleEdge(vertex12,vertex18), health(4), visibleEdge(vertex12,vertex19), visibleVertex(vertex7,B), visibleEdge(vertex3,vertex13), lastActionResult(successful), visibleVertex(vertex12,A), visibleEdge(vertex12,vertex13), visibleVertex(vertex3,B), visibleEntity(a2,vertex4,A,normal), visibleVertex(vertex11,none), visibleEntity(b5,vertex6,B,normal), visibleVertex(vertex19,B), visibleEntity(b10,vertex4,B,normal), visibleEntity(b2,vertex19,B,normal), maxEnergyDisabled(12), timestamp(1302117414629), money(0), visibleEntity(a10,vertex15,A,normal), visibleEntity(a7,vertex10,A,normal), visibleEdge(vertex4,vertex6), visibleEdge(vertex13,vertex18), visibleEdge(vertex4,vertex7), visibleEntity(b9,vertex4,B,normal), visibleVertex(vertex6,B), visibleEdge(vertex0,vertex7), zonesScore(5), strength(0), position(vertex12), visibleVertex(vertex13,B), visibleEntity(b1,vertex5,B,normal), visibleEdge(vertex13,vertex17), visibleEdge(vertex13,vertex14), maxEnergy(12), visibleEntity(b3,vertex7,B,normal), visibleEdge(vertex7,vertex12), step(598), maxHealth(4), visibleEntity(a1,vertex12,A,normal), visibleEdge(vertex7,vertex19), visibleEntity(b6,vertex4,B,normal), visibleEdge(vertex7,vertex15), visibleVertex(vertex14,none), visibleEntity(b4,vertex13,B,normal), visibleEdge(vertex10,vertex13), zoneScore(0), visibleVertex(vertex10,A), visibleEdge(vertex14,vertex18), lastAction(skip), visibleEntity(b8,vertex11,B,normal), requestAction, deadline(1302117424629), visibleVertex(vertex0,B), visibleVertex(vertex17,A), visibleEdge(vertex6,vertex7), visibleEntity(b7,vertex0,B,normal), visibleVertex(vertex18,none), visibleVertex(vertex4,B), visibleEdge(vertex11,vertex14), visibleVertex(vertex15,A), visRange(2), visibleVertex(vertex5,none), visibleEdge(vertex11,vertex12), lastStepScore(5), visibleEdge(vertex6,vertex13), visibleEdge(vertex6,vertex12), visibleEdge(vertex15,vertex19), energy(12), visibleEntity(a4,vertex11,A,normal), visibleEntity(a3,vertex5,A,normal), visibleEntity(a5,vertex17,A,normal), visibleEdge(vertex11,vertex19), visibleEdge(vertex11,vertex18), score(2990), visibleEdge(vertex5,vertex6)]

visibleEntity(a2,vertex4,A,normal)

lastActionResult(successful)
lastAction(skip)

def print_perceptions(percepts)
  result = ""
  percepts.each do |percept|
    # Idea: take these results of form visibleEdge(vertex3,vertex6) to
    # eval directly to ruby classes, or even better, prolog facts
    case "#{percept}"
    when /lastAction\((.*)\)/
      puts "#{@name}'s action: #$1"
    when /lastActionResult\((.*)\)/
      puts "#{@name}'s result: #$1"
    else
      #
    end
  end
  result
end


# Test percepts
percepts.each do |percept|
  # puts " - #{percept}"
end

puts print_perceptions percepts unless percepts.empty?

sleep 1 if @name == "a3"

# Test actions
@adapter.act! @name, MassimActions::goto_action("node1") if @name == "a1"
@adapter.act! @name, MassimActions::recharge_action if @name == "a2"

# Test cycle
deliberate if (@name == "a3" && percepts.any?)


----- Magic Experiments

# Base

# TODO
# All following stuff should be put into a belief class based on
# BaseObject, to get rid of all predefined methods on object

def self.infer(*args, &block)
  puts "Infer method with args #{args}"
  block.call
end

def self.method_missing(sym, *args, &block)
  define_method(sym) do
    @ivars[sym]
  end
  
  define_method("#{sym}=".to_sym) do |value|
    @ivars[sym] = value
  end
  
  return ( args.any? ? "#{sym}(#{args})" : "#{sym}" )
end

def self.inherited(klass)
  klass.define_method(:method_missing) do |sym, *args|
    puts "Warning: Call to undefined predicate #{sym}(#{args})"
    
    define_method(sym) do
      @ivars[sym]
    end

    define_method("#{sym}=".to_sym) do |value|
      @ivars[sym] = value
    end
    
    # Retry with new methods
    return ""
  end
end

# Inherited Agent

infer lastAction do
  puts "Inner block called"
  lastAction = testAction
  puts "Test: #{lastAction} (#{lastAction.class})"
end

infer lastAction(test_argument) do
  puts "Second inner block called"
end

# infer lastActionResult => [ test(argument), test2(argument2) ]

----

### BETTER GOALHANDLING

on :goal_name do
  context do
    
  end
  
  plan do
    
  end
end