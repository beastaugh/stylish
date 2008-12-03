require 'test/unit'
require './lib/stylish'

class StylesheetTest < Test::Unit::TestCase
  
  def test_nested_rules
    style = Stylish::Stylesheet.new do
      rule ".header", "display" => "block"
      rule ".content", :bgcolor => "#00FF00"
      rule ".footer", "font-weight" => "bold"
    end
    
    assert_equal(3, style.rules.length)
    assert_equal(".header {display:block;}", style.rules[0].to_s)
    
    style.rules.each do |rule|
      assert_instance_of(Stylish::Rule, rule)
    end
  end

end
