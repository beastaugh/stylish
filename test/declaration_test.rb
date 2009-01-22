require 'test/unit'
require './lib/stylish'

class DeclarationTest < Test::Unit::TestCase
    
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
