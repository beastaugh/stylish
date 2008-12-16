require 'test/unit'
require './lib/stylish'

class ColorTest < Test::Unit::TestCase
  
  def setup
    @red = Stylish::Color.new(:red)
    @green = Stylish::Color.new(:green)
    @blue = Stylish::Color.new("#0000FF")
    @white = Stylish::Color.new("#FFF")
    @yellow = Stylish::Color.new([0, 0, 255])
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
  
  def test_rgb_values
    assert_equal([0, 0, 255], @yellow.value)
    assert_equal([255, "100%", -10], Stylish::Color.new("rgb(255, 100%, -10)").value)
    assert_equal([255, "100%", 0], Stylish::Color.new("255, 100%, -0").value)
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
  
  def test_invalid_rgb_values
    assert_raise ArgumentError do
      Stylish::Color.new("512, 0, 0")
    end
    
    assert_raise ArgumentError do
      Stylish::Color.new("200%, 0, 0")
    end
    
    assert_raise ArgumentError do
      Stylish::Color.new("128, 128")
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
