class DeclarationTest < Test::Unit::TestCase
  
  def setup
    @declaration = Stylish::Declaration.new("color", Stylish::Color.new("000"))
  end
  
  def test_naming
    assert_equal("color", @declaration.name)
  end
  
  def test_value
    assert_equal("#000", @declaration.value.to_s)
  end
  
  def test_to_string
    assert_equal("color:#000;", @declaration.to_s)
  end
end
