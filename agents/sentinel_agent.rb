require 'agents/simple_agent'

class SentinelAgent < SimpleAgent
  
  def setup
    super
    bb.role = "Sentinel"
  end
  
end