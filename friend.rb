class Friend
  attr_accessor :name, :health, :max_health, :position, :role
  
  def initialize(name, health, max_health)
    @name = name
    @health = health
    @max_health = max_health
  end
  
  def disabled?
    @health == 0
  end
  
  def injured?
    @health < @max_health
  end
  
  def <=>(other)
    return unless other.is_a? Friend
    return @health <=> other.health
  end
end