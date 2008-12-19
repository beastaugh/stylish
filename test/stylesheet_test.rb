require 'test/unit'
require './lib/stylish'

class StylesheetTest < Test::Unit::TestCase
  
  def test_improper_rules
    style = Stylish::Stylesheet.new
    style.rules = ["really", "not", "what", "we", "want"]
    assert_equal(0, style.rules.length)
  end
  
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
    assert_equal(".namespace .header {color:#0000ff;}", style.rules[4].to_s)
    
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
  
  def test_image_paths
    style = Stylish::Stylesheet.new(nil, nil, :images => '/public/images/') do
      rule ".header", "background-image" => image("test.png")
    end
    
    assert_equal("url('/public/images/test.png')", style.rules[0].declarations[0].value)
  end
  
  def test_backgrounds
    style = Stylish::Stylesheet.new do
      rule "#wrapper", background(:color => "red", :image => "background.jpg")
      rule "#header", background(:color => "red", :image => "background.jpg",
        :repeat => "no-repeat", :position => "left top", :compressed => true)
    end
    
    assert(style.rules[1].declarations[0].compressed)
    assert_equal("#wrapper {background-color:#ff0000; background-image:url('background.jpg');}", style.rules[0].to_s)
    assert_equal("#header {background:#ff0000 url('background.jpg') no-repeat left top;}", style.rules[1].to_s)
  end
  
  def test_image_path_nesting_with_backgrounds
    style = Stylish::Stylesheet.new(nil, nil, :images => '/public/images/') do
      rule ".content", background(:image => "wallpaper.gif", :repeat => "repeat")
    end
    
    assert_equal("url('/public/images/wallpaper.gif')", style.rules[0].declarations[0].image)
  end
  
  def test_comments
    style = Stylish::Stylesheet.new do
      comment "Content areas should be spaced out."
      rule ".content", "margin" => "1em 0"
    end
    
    assert_instance_of(Stylish::Comment, style.content[0])
    assert_equal("Content areas should be spaced out.", style.content[0].header)
  end
end
