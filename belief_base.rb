class BeliefBase
  
  attr_accessor :transient
  
  def initialize()
    @beliefs = Hash.new
    @transient = Hash.new
    yield( self ) if block_given?
  end
  
  def new_cycle
    @transient.clear
  end
  
  def empty?
    return @beliefs.empty?
  end
  
  
  # TODO: Think about base class, so there will be no conflicts
  #       with method names
  
  def method_missing(sym, *args)
    if sym.to_s =~ /^[A-Za-z0-9_]*$/
      return *( @beliefs[sym] )
    elsif sym.to_s =~ /^[A-Za-z0-9_]*=$/
      sym = sym.to_s[0..-2].to_sym
      return @beliefs[sym] = args
    else
      return super
    end
  end
end