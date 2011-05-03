class Enemy
  attr_reader :name, :team, :position, :disabled
  
  def initialize(name, position, team, status)
    @name = name
    @team = team
    @position = position
    @disabled = ( status == "disabled" ? true : false )
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