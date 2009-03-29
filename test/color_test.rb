require 'test/unit'
require './lib/stylish'

class ColorTest < Test::Unit::TestCase
  
  def setup
    @red = Stylish::Color.new(:red)
    @green = Stylish::Color.new(:green)
    @blue = Stylish::Color.new("#0000FF")
    @white = Stylish::Color.new("#FFF")
    @yellow = Stylish::Color.new([255, 255, 0])
    @inherit = Stylish::Color.new("inherit")
    @transparent = Stylish::Color.new("transparent")
  end
  
  def test_inherit
    assert_equal("inherit", @inherit.value)
  end
  
  def test_transparency
    assert_equal([0, 0, 0, 0], @transparent.value)
    assert_equal("transparent", @transparent.to_s)
  end
  
  def test_real_keywords
    assert_equal("red", @red.to_keyword)
    assert_equal(:keyword, @red.type)
    
    assert_equal("green", @green.to_keyword)
    assert_equal(:keyword, @green.type)
  end
  
  def test_valid_hex_values
    assert_equal("#00f", @blue.to_hex)
    assert_equal(:hex, @blue.type)
    
    assert_equal("#fff", @white.to_hex)
    assert_equal(:hex, @white.type)
  end
  
  def test_rgb_values
    assert_equal([255, 255, 0, nil], @yellow.value)
    assert_equal([255, 255, 10, nil],
      Stylish::Color.new("rgb(255, 100%, 10)").value)
  end
  
  def test_rgba_values
    assert_equal([255, 255, 10, 0.8],
      Stylish::Color.new("rgba(255, 100%, 10, 0.8)").value)
  end
  
  def test_hsl_values
    assert_equal([255, 64, 64, nil],
      Stylish::Color.new("hsl(0, 100%, 63%)").value)
    assert_equal([96, 64, 32, nil],
      Stylish::Color.new("hsl(30, 50%, 25%)").value)
    assert_equal([0, 0, 0, nil],
      Stylish::Color.new("hsl(90, 0%, 0%)").value)
    assert_equal([255, 255, 255, nil],
      Stylish::Color.new("hsl(120, 0%, 100%)").value)
  end
  
  def test_case_insensitivity_of_keywords
    assert_equal([0, 128, 0, nil], Stylish::Color.new(:Green).value)
    assert_equal([0, 128, 0, nil], Stylish::Color.new(:GrEeN).value)
    assert_equal([0, 128, 0, nil], Stylish::Color.new("Green").value)
    assert_equal([0, 128, 0, nil], Stylish::Color.new("GrEeN").value)
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
    assert_equal([0, 0, 0, nil], Stylish::Color.new("rgb(0, 0, 0)").value)
    
    assert_raise ArgumentError do
      Stylish::Color.new("rgb(0 0 0)")
    end
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
    assert_equal("rgb(255, 255, 0)", @yellow.to_s)
    assert_equal("rgb(255, 128, 0)",
      Stylish::Color.new("rgb(100%, 50%, 0)").to_s)
  end
  
  def test_rgba_to_string
    assert_equal("rgba(255, 128, 0, 0.5)",
      Stylish::Color.new("rgba(100%, 50%, 0%, 0.5)").to_s)
  end
  
  # def test_hsl_to_string
  #   assert_equal("hsl(0, 100%, 63%)",
  #     Stylish::Color.new("hsl(0, 100%, 63%)").to_s)
  #   assert_equal("hsl(30, 50%, 25%)",
  #     Stylish::Color.new("hsl(30, 50%, 25%)").to_s)
  #   assert_equal("hsl(90, 0%, 0%)",
  #     Stylish::Color.new("hsl(90, 0%, 0%)").to_s)
  #   assert_equal("hsl(120, 0%, 100%)",
  #     Stylish::Color.new("hsl(120, 0%, 100%)").to_s)
  # end
  
  def test_inherit_and_transparent_to_hex
    assert_nil(Stylish::Color.new(:inherit).to_hex)
    assert_nil(Stylish::Color.new(:transparent).to_hex)
  end
  
  def test_hex_to_hex
    assert_equal("#fff", Stylish::Color.new("FFF").to_hex)
    assert_equal("#fff", Stylish::Color.new("#FFF").to_hex)
    assert_equal("#e5e5e5", Stylish::Color.new("e5e5e5").to_hex)
    assert_equal("#e5e5e5", Stylish::Color.new("#e5e5e5").to_hex)
  end
  
  def test_keywords_to_hex
    assert_equal("#808080", Stylish::Color.new(:gray).to_hex)
    assert_equal("#800000", Stylish::Color.new(:maroon).to_hex)
  end
  
  def test_rgb_to_hex
    assert_equal("#5097ba", Stylish::Color.new([80, 151, 186]).to_hex)
    assert_equal("#5097ba", Stylish::Color.new([80, 151, 186]).to_hex)
    assert_equal("#010409", Stylish::Color.new([1, 4, 9]).to_hex)
  end
  
  def test_to_hex_compression
    assert_equal("#fff", Stylish::Color.new([255, 255, 255]).to_hex)
    assert_equal("#fff", Stylish::Color.new("#ffffff").to_hex)
    assert_equal("#fb0", Stylish::Color.new("#ffbb00").to_hex)
    assert_equal("#0ff", Stylish::Color.new(:aqua).to_hex)
  end
end
