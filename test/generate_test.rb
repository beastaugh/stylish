require 'test/unit'
require './lib/stylish'

class GenerateTest < Test::Unit::TestCase
  
  def setup
    @style = Stylish.generate do
      rule ".header", background(:color => :green)
      
      rule ".content" do
        rule "H1", font_size("2em")
        rule "P", margin_bottom("10px")
      end
    end
  end
  
  def test_generate_shortcut
    assert_equal(3, @style.rules.length)
    assert_equal(".header {background-color:green;}", @style.rules[0].to_s)
    assert_equal(".content P {margin-bottom:10px;}", @style.rules[2].to_s)
  end
  
  def test_write_style
    @style.write
    css_string = File.read(@style.name + '.css')
    
    assert_equal(@style.to_s, css_string)
    
    `rm #{@style.name}.css`
  end
  
  def test_subsheets
    greek = Stylish.generate do
      ["alpha", "beta", "gamma", "delta"].each do |name|
        subsheet(name) {
          comment "#{name.capitalize} is a sub-stylesheet."
          rule "DIV", font_style("normal"), margin("0 0 1em 0")
          rule "P", text_indent("-9999em")
        }
      end
    end
    
    assert_equal(4, greek.subsheets.length)
    
    3.times do |i|
      assert_instance_of(Stylish::Stylesheet, greek.subsheets[i])
      assert_equal(3, greek.subsheets[i].content.length)
    end
  end
  
  def test_subsheet_indents
    tree = Stylish.generate do
      subsheet do
        rule "P", text_indent("-9999em")
        
        subsheet do
          rule "EM", font_style("italic")
        end
      end
    end
    
    lines = tree.to_s.split("\n")
    
    assert_equal("  P {text-indent:-9999em;}", lines[0])
    assert_equal("    EM {font-style:italic;}", lines[1])
    
    tree.indent = ""
    
    assert_equal("P {text-indent:-9999em;}", tree.to_s.split("\n")[0])
  end
end
