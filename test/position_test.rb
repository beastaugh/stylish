class PositionTest < Test::Unit::TestCase
  
  def setup
    @pos = Stylish::Position.new(0, 0)
  end
  
  def test_percentage_positions
    percentage = Stylish::Position.new("5%", "10%")
    assert_equal("5%", percentage.x)
    assert_equal("10%", percentage.y)
  end
  
  def test_keyword_positions
    keyed = Stylish::Position.new("left", "top")
    assert_equal("left", keyed.x)
    assert_equal("top", keyed.y)
  end
  
  def test_serialisation
    assert_equal("0 0", @pos.to_s)
  end
end
