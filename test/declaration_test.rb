require 'test/unit'
require './lib/stylish'

class DeclarationTest < Test::Unit::TestCase
  
  def test_shorthands
    dec = Stylish::Declaration.new(:bgcolor, "#fff")
    assert_equal("background-color", dec.property)
    
    dec.property = :bdcolor
    assert_equal("border-color", dec.property)
  end
  
  def test_colors
    assert_instance_of(Stylish::Color, Stylish::Declaration.new("color", :green).value)
    assert_instance_of(Stylish::Color, Stylish::Declaration.new("color", "#e5e5e5").value)
    assert_instance_of(Stylish::Color, Stylish::Declaration.new("color", "rgb(255 255 0)").value)
  end
  
  def test_empty_value
    hollow = Stylish::Declaration.new("cursor")
    
    assert_not_nil(hollow.property)
    assert_nil(hollow.value)
  end
  
  def test_to_string
    dec = Stylish::Declaration.new("color", "#000")
    assert_equal("color:#000;", dec.to_s)
  end
end
