require 'agents/explorer_agent'
require 'agents/inspector_agent'
require 'agents/repairer_agent'
require 'agents/sentinel_agent'

require 'experimental/exp_modules'

class ParryExplorerAgent < ExplorerAgent
  include ParryComponents
end

class ParryInspectorAgent < InspectorAgent
  include ParryComponents
end

class ParryRepairerAgent < RepairerAgent
  include ParryComponents
end

class ParrySentinelAgent < SentinelAgent
  include ParryComponents
end

