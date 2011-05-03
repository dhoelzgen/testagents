class ExampleClass
  @variable = "foo"
  @@variable = "bar"
  
  def initialize
    @variable = "baz"
  end
  
  def self.test
    @variable
  end
  
  def test
    puts self.class.test
    puts @@variable
    puts @variable
  end
end

class ExampleSubclass < ExampleClass
  @variable = base.test
  @@variable = "2"
  
  def initialize
    @variable = "3"
  end
end

first_example = ExampleClass.new
first_example.test

puts "---"

second_example = ExampleSubclass.new
second_example.test