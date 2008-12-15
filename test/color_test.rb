require 'test/unit'
require './lib/stylish'

class ColorTest < Test::Unit::TestCase
  
  def setup
    @red = Stylish::Color.new(:red)
    @green = Stylish::Color.new(:green)
    @blue = Stylish::Color.new("#0000FF")
    @white = Stylish::Color.new("#FFF")
  end
  
  def test_real_keywords
    assert_equal("ff0000", @red.value)
    assert_equal(:keyword, @red.type)
    
    assert_equal("008000", @green.value)
    assert_equal(:keyword, @green.type)
  end
  
  def test_valid_hex_values
    assert_equal("0000ff", @blue.value)
    assert_equal(:hex, @blue.type)
    
    assert_equal("fff", @white.value)
    assert_equal(:hex, @white.type)
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
  
  def test_hex_to_string
    assert_equal('#999', Stylish::Color.new('#999').to_s)
    assert_equal('#ccc', Stylish::Color.new('CCC').to_s)
  end
  
  def test_keyword_to_string
    assert_equal('#008000', @green.to_s)
    assert_equal('#ffff00', Stylish::Color.new(:yellow).to_s)
  end
  
end
