require 'test/unit'
require './lib/stylish'

class RuleTest < Test::Unit::TestCase
  
  def setup
    @rule = Stylish::Rule.new(".content, .form", "font-weight:normal; color:#000;")
  end
  
  def test_format
    assert_equal(".content, .form {font-weight:normal; color:#000;}", @rule.to_s)
  end
  
  def test_declaration_input_types
    selector = Stylish::Selector.new('.test')
    rstr = Stylish::Rule.new(selector, "text-transform:uppercase;")
    rhsh = Stylish::Rule.new(selector, {"text-transform" => "lowercase"})
    
    assert_equal("text-transform", rstr.declarations[0].property)
    assert_equal("uppercase", rstr.declarations[0].value)
    
    assert_equal("text-transform", rhsh.declarations[0].property)
    assert_equal("lowercase", rhsh.declarations[0].value)
  end
  
  def test_declaration_types
    @rule.declarations.each do |d|
      assert_instance_of(Stylish::Declaration, d)
    end
  end
  
  def test_selector_types
    @rule.selectors.each do |d|
      assert_instance_of(Stylish::Selector, d)
    end
  end
end
