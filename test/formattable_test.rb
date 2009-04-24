require 'test/unit'

class FormattableTest < Test::Unit::TestCase
  
  def setup
    @selectors = Stylish::Selectors.new
    @declaration = Stylish::Declaration.new("background-color", "#000")
    @background = Stylish::Background.new("color" => "red")
  end
  
  def test_reading_default_formats  
    assert_equal(", ", @selectors.format)
    assert_equal("%s:%s;", @declaration.format)
    assert_equal("%s:%s;", @declaration.format)
  end
  
  def test_setting_allowed_formats
    assert_nothing_raised do
      @selectors.format = ",\n"
    end
  end
  
  def test_setting_disallowed_formats
    assert_raise ArgumentError do
      @selectors.format = "//"
    end
  end
  
  class ConfusedAboutFormatting
    include Stylish::Formattable
  
    def initialize
      accept_format(/^\s*$/, "///")
    end
  end
  
  def test_class_definition_with_disallowed_format
    assert_raise ArgumentError do
      ConfusedAboutFormatting.new
    end
  end
end
