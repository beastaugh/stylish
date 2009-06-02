class FormattableTest < Test::Unit::TestCase
  
  def test_reading_default_formats  
    assert_equal(", ", Stylish::Selectors.format)
    assert_equal("%s:%s;", Stylish::Declaration.format)
    assert_equal("%s:%s;", Stylish::Background.format)
  end
  
  def test_setting_allowed_formats
    assert_nothing_raised do
      Stylish::Selectors.format = ",\n"
      Stylish::Selectors.format = ", "
    end
  end
  
  def test_setting_disallowed_formats
    assert_raise ArgumentError do
      Stylish::Selectors.format = "//"
    end
  end
  
  def test_changing_formats
    Stylish::Declarations.format = "\n"
    assert_equal("\n", Stylish::Declarations.format)
    
    Stylish::Declarations.format = ""
    assert_equal("", Stylish::Declarations.format)
    
    Stylish::Declarations.format = " "
    assert_equal(" ", Stylish::Declarations.format)
  end
end
