require 'test/unit'
require './lib/stylish'

class ColorTest < Test::Unit::TestCase
  
  def setup
    @red = Stylish::Color.new(:red)
    @green = Stylish::Color.new(:green)
    @blue = Stylish::Color.new("#0000FF")
    @white = Stylish::Color.new("#FFF")
    @yellow = Stylish::Color.new([0, 0, 255])
    @inherit = Stylish::Color.new("inherit")
    @transparent = Stylish::Color.new("transparent")
  end
  
  def test_inherit
    assert_equal("inherit", @inherit.value)
  end
  
  def test_transparency
    assert_equal("transparent", @transparent.value)
  end
  
  def test_real_keywords
    assert_equal(:red, @red.value)
    assert_equal(:keyword, @red.type)
    
    assert_equal(:green, @green.value)
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
    assert_equal([255, "100%", -10],
      Stylish::Color.new("rgb(255, 100%, -10)").value)
    assert_equal([255, "100%", 0],
      Stylish::Color.new("255, 100%, -0").value)
  end
  
  def test_rgba_values
    assert_equal([255, "100%", -10, 0.8],
      Stylish::Color.new("rgb(255, 100%, -10, 0.8)").value)
  end
  
  def test_case_insensitivity_of_keywords
    assert_equal(:green, Stylish::Color.new(:Green).value)
    assert_equal(:green, Stylish::Color.new(:GrEeN).value)
    assert_equal(:green, Stylish::Color.new("Green").value)
    assert_equal(:green, Stylish::Color.new("GrEeN").value)
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
  
  def test_overly_large_rgb_values
    assert_raise ArgumentError do
      Stylish::Color.new("512, 0, 0")
    end
  end
  
  def test_wrong_number_of_rgb_values
    assert_raise ArgumentError do
      Stylish::Color.new("128, 128")
    end
  end
  
  def test_comma_separation_of_rgb_values
    assert_equal([0, 0, 0, 0], Stylish::Color.new("0, 0, 0, 0").value)
    assert(Stylish::Color.like?("0, 0, 0, 0"))
    assert(!Stylish::Color.like?("0 0 0 0"))
  end
  
  def test_inherit_to_string
    assert_equal("inherit", @inherit.to_s)
  end
  
  def test_hex_to_string
    assert_equal('#999', Stylish::Color.new('#999').to_s)
    assert_equal('#ccc', Stylish::Color.new('CCC').to_s)
  end
  
  def test_keyword_to_string
    assert_equal("green", @green.to_s)
    assert_equal("yellow", Stylish::Color.new(:yellow).to_s)
  end
  
  def test_rgb_to_string
    assert_equal("rgb(0, 0, 255)", @yellow.to_s)
    assert_equal("rgb(100%, 50%, 0)",
      Stylish::Color.new("rgb(100%, 50%, -0)").to_s)
  end
  
end
