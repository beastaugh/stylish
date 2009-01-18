require 'test/unit'
require './lib/stylish'

class StylesheetTest < Test::Unit::TestCase
  
  def setup
    @style = Stylish::Stylesheet.new
  end
  
  def test_name_assignment
    @style.name = "rothko"
    assert_equal("rothko", @style.name)
    
    @style.name = 123456
    assert_equal("rothko", @style.name)
    
    some_style = Stylish::Stylesheet.new
    assert_equal(some_style.object_id.to_s, some_style.name)
  end
  
  def test_name_return_type
    assert_instance_of(String, @style.name)
  end
  
  def test_content_assignment
    @style.content = [Stylish::Rule.new(".content", "color" => "red"),
                      Stylish::Comment.new("Test comment")]
    assert_equal(2, @style.content.length)
  end
  
  def test_improper_content_assignment
    @style.content = ["various", "objects", "that", "are", "incorrect"]
    assert_equal(0, @style.content.length)
  end
  
  def test_rules_assignment
    @style.content = [Stylish::Comment.new("Test comment")]
    @style.rules = [Stylish::Rule.new(".content", "color" => "red")]
    assert_equal(1, @style.rules.length)
    assert_equal(2, @style.content.length)
    
    @style.rules = []
    assert_equal(0, @style.rules.length)
  end
  
  def test_improper_rules_assignment
    @style.rules = ["really", "not", "what", "we", "want"]
    assert_equal(0, @style.rules.length)
    
    @style.rules = [Stylish::Comment.new("Test comment")]
    assert_equal(0, @style.rules.length)
  end
  
  def test_comments_assignment
    @style.content = [Stylish::Rule.new(".content", "color" => "red")]
    @style.comments = [Stylish::Comment.new("Test comment")]
    
    assert_equal(2, @style.content.length)
    assert_equal(1, @style.comments.length)
  end
  
  def test_improper_comments_assignment
    @style.content = [Stylish::Rule.new(".content", "color" => "red"),
                      Stylish::Comment.new("Test comment")]
    @style.comments = ["these", "aren't", "comments!"]
    assert_equal(0, @style.comments.length)
    assert_equal(1, @style.content.length)
  end
  
  def test_stylesheet_assignment
    @style.content = [Stylish::Rule.new(".content", "color" => "red"),
                      Stylish::Comment.new("Test comment"),
                      Stylish::Stylesheet.new]
    assert_equal(3, @style.content.length)
    
    @style.subsheets = [Stylish::Stylesheet.new, Stylish::Stylesheet.new]
    assert_equal(4, @style.content.length)
  end
  
  def test_improper_stylesheet_assignment
    @style.content = [Stylish::Rule.new(".content", "color" => "red"),
                      Stylish::Comment.new("Test comment"),
                      Stylish::Stylesheet.new]
    @style.subsheets = ["strings", "aren't", "styles!"]
    
    assert_equal(0, @style.subsheets.length)
    assert_equal(2, @style.content.length)
  end
  
  def test_nested_rules
    style = Stylish::Stylesheet.new do
      rule ".header", display("block")
      rule ".content", bgcolor("#00FF00")
      rule ".footer", font_weight("bold")
      
      rule ".namespace" do
        rule ".header", color("#0000FF")
        rule ".content" do
          rule "p", margin("0 0 1em 0")
          rule "code", display("inline")
        end
        rule ".footer", bdcolor("#999")
      end
    end
    
    assert_equal(7, style.rules.length)
    assert_equal(".header {display:block;}", style.rules[0].to_s)
    assert_equal(".namespace .header {color:#0000ff;}", style.rules[3].to_s)
    
    style.rules.each do |rule|
      assert_instance_of(Stylish::Rule, rule)
    end
    
    nested = Stylish::Stylesheet.new(nil, ".section") do
      rule "p", font_weight("normal"), margin_bottom("1em")
      rule "h3", font_weight("bold")
    end
    
    assert_equal(2, nested.rules.length)
    
    flattened = nested.rules.map {|r| r.to_s }
    assert_nil(flattened.index(".section {}"))
    assert_not_nil(flattened.index(".section p {font-weight:normal; margin-bottom:1em;}"))
    assert_not_nil(flattened.index(".section h3 {font-weight:bold;}"))
  end
  
  def test_rule_order
    style = Stylish::Stylesheet.new do
      rule "p", margin("0 0 1em 0"), font_weight("normal")
    end
    
    assert_equal("margin:0 0 1em 0;", style.rules[0].declarations[0].to_s)
    assert_equal("font-weight:normal;", style.rules[0].declarations[1].to_s)
  end
  
  def test_compact_rules_without_blocks
    style = Stylish::Stylesheet.new do
      rule ".content, .context" do
        rule "h3", font_weight("bold")
        rule ".generic, .special", display("block")
      end
    end
    
    assert_equal(4, style.rules.length)
    assert_equal(".content .generic, .content .special {display:block;}", style.rules[1].to_s)
  end
  
  def test_image_paths
    style = Stylish::Stylesheet.new(nil, nil, nil, :images => '/public/images/') do
      rule ".header", background_image(image("test.png"))
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
    assert_equal("#wrapper {background-color:red; background-image:url('background.jpg');}", style.rules[0].to_s)
    assert_equal("#header {background:red url('background.jpg') no-repeat left top;}", style.rules[1].to_s)
  end
  
  def test_image_path_nesting_with_backgrounds
    style = Stylish::Stylesheet.new(nil, nil, nil, :images => '/public/images/') do
      rule ".content", background(:image => "wallpaper.gif", :repeat => "repeat")
    end
    
    assert_equal("url('/public/images/wallpaper.gif')", style.rules[0].declarations[0].image)
  end
  
  def test_comments
    style = Stylish::Stylesheet.new do
      comment "Content areas should be spaced out."
      rule ".content", margin("1em 0")
    end
    
    assert_instance_of(Stylish::Comment, style.content[0])
    assert_equal("Content areas should be spaced out.", style.content[0].header)
    assert_equal("Content areas should be spaced out.", style.comments[0].header)
  end
  
  def test_indenting
    style = Stylish::Stylesheet.new(nil, nil, nil, :depth => 1, :indent => " " * 2) do
      comment "Testing comment indents"
      rule "P", font_weight("normal")
      rule "DIV", margin_bottom("0")
    end
    
    assert_equal(
"  /**
   * Testing comment indents
   */
  P {font-weight:normal;}
  DIV {margin-bottom:0;}", style.to_s)
  end
end
