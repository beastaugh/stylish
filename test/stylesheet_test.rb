require 'test/unit'
require './lib/stylish'

class StylesheetTest < Test::Unit::TestCase
  
  def test_nested_rules
    style = Stylish::Stylesheet.new do
      rule ".header", "display" => "block"
      rule ".content", :bgcolor => "#00FF00"
      rule ".footer", "font-weight" => "bold"
      
      rule ".namespace" do
        rule ".header", "color" => "#0000FF"
        rule ".content" do
          rule "p", "margin" => "0 0 1em 0"
          rule "code", "display" => "inline"
        end
        rule ".footer", :bdcolor => "#999"
      end
      
      rule do
        rule "p", :bgcolor => "#e5e5e5"
      end
    end
        
    assert_equal(9, style.rules.length)
    assert_equal(".header {display:block;}", style.rules[0].to_s)
    assert_equal(".namespace .header {color:#0000FF;}", style.rules[4].to_s)
    
    style.rules.each do |rule|
      assert_instance_of(Stylish::Rule, rule)
    end
    
    nested = Stylish::Stylesheet.new ".section" do
      rule "p", "font-weight" => "normal", "margin-bottom" => "1em"
      rule "h3", "font-weight" => "bold"
    end
    
    assert_equal(2, nested.rules.length)
    
    flattened = nested.rules.map {|r| r.to_s }
    
    assert_nil(flattened.index(".section {}"))
    assert_not_nil(flattened.index(".section p {font-weight:normal; margin-bottom:1em;}"))
    assert_not_nil(flattened.index(".section h3 {font-weight:bold;}"))
  end

end
