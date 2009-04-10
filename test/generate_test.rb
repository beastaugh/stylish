require 'test/unit'
require './lib/stylish'

class GenerateTest < Test::Unit::TestCase
  
  def test_simple_rules
    style = Stylish.generate do
      rule ".checked", :font_weight => "bold"
      rule ".unchecked", :font_style => "italic"
    end
    
    assert_equal(".checked {font-weight:bold;}\n" +
      ".unchecked {font-style:italic;}", style.to_s)
  end
  
  def test_nested_rules
    style = Stylish.generate do
      rule "body" do
        rule ".gilded" do
          rule ".lily", :color => "gold"
        end
        
        rule "form", :line_height => "1"
        rule "fieldset", :text_indent => "1em"
      end
    end
    
    assert_equal("body .gilded .lily {color:gold;}\n" +
      "body form {line-height:1;}\n" +
      "body fieldset {text-indent:1em;}", style.to_s)
  end
  
  def test_element_rules
    style = Stylish.generate do
      body :z_index => 1000
      p :line_height => "1.5"
    end
    
    assert_equal("body {z-index:1000;}\n" +
      "p {line-height:1.5;}", style.to_s)
  end
  
  def test_nested_element_rules
    style = Stylish.generate do
      body do
        div do
          p :line_height => "1.5"
        end
      end
    end
    
    assert_equal("body div p {line-height:1.5;}", style.to_s)
  end
end
