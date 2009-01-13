require 'test/unit'
require './lib/stylish'

class GenerateTest < Test::Unit::TestCase
  
  def test_generate_shortcut
    style = Stylish.generate do
      rule ".header", background(:color => :green)
      
      rule ".content" do
        rule "H1", font_size("2em")
        rule "P", margin_bottom("10px")
      end
    end
    
    assert_equal(3, style.rules.length)
    assert_equal(".header {background-color:green;}", style.rules[0].to_s)
    assert_equal(".content P {margin-bottom:10px;}", style.rules[2].to_s)
  end
end
