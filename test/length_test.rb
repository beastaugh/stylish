class LengthTest < Test::Unit::TestCase
  
  def test_different_units
    assert_equal("px", Stylish::Length.new("10px").unit)
  end
  
  def test_serialisation
    length = Stylish::Length.new("5em")
    assert_equal("5em", length.to_s)
  end
  
  def test_accessors
    length = Stylish::Length.new("30mm")
    length.unit  = "px"
    length.value = 50
    
    assert_equal("px", length.unit)
    assert_equal(50, length.value)
  end
end
