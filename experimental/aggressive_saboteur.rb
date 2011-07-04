require 'agents/saboteur_agent'
require 'experimental/exp_modules'

class AggressiveSaboteurAgent < SaboteurAgent
  include AggressiveTarget
end