class Enemy
  attr_accessor :name, :team, :position, :disabled
  attr_accessor :role, :max_energy, :max_health
  
  def initialize(name, position, team, status)
    @name = name
    @team = team
    @position = position
    @disabled = ( status == "disabled" ? true : false )
  end
  
  def set_inspected(role, max_energy, max_health)
    @role = role
    @max_energy = max_energy
    @max_health = max_health
  end
  
  def inspected?
    return ( @role ? true : false )
  end
  
  def status=(status)
    @disabled = ( status == "disabled" ? true : false )
  end
  
  def enabled
    !@disabled
  end
  
  def priority
    # TODO: Add strength and use it
    return (disabled ? -1 : 1)
  end
  
  def <=>(other)
    return unless other.is_a? Enemy
    return priority <=> other.priority
  end
end