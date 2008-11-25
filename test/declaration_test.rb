require 'test/unit'
require './lib/stylish'

class DeclarationTest < Test::Unit::TestCase
  
  def test_shorthands
    dec = Stylish::Declaration.new(:bgcolor, "#fff")
    assert_equal("background-color", dec.property)
    
    dec.property = :bdcolor
    assert_equal("border-color", dec.property)
  end
  
  def test_to_string
    dec = Stylish::Declaration.new("color", "#000")
    assert_equal("color:#000;", dec.to_s)
  end
end
