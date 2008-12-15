require 'test/unit'
require './lib/stylish'

class ColorTest < Test::Unit::TestCase
  
  def test_keywords
    red = Stylish::Color.new(:red)
    assert_equal("ff0000", red.value)
  end
  
  def test_valid_hex_values
    blue = Stylish::Color.new("#0000FF")
    white = Stylish::Color.new("#FFF")
    
    assert_equal("0000ff", blue.value)
    assert_equal("fff", white.value)
  end
  
  def test_nonexistent_keywords
    assert_raise ArgumentError do
      Stylish::Color.new("burnt-umber")
    end
  end
  
  def test_invalid_hex_values
    assert_raise ArgumentError do
      Stylish::Color.new("#XYZ")
    end
  end
  
end
