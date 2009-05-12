class GenerateTest < Test::Unit::TestCase
  
  def test_simple_rules
    style = Stylish.generate do
      rule ".checked", :font_weight => "bold"
      rule ".unchecked", :font_style => "italic"
    end
    
    assert_equal(".checked {font-weight:bold;}\n" +
      ".unchecked {font-style:italic;}", style.to_s)
  end
  
  def test_compound_rules
    style = Stylish.generate do
      rule ["abbr", "acronym"], :margin_bottom => "2em"
    end
    
    assert_equal(1, style.rules.length)
    assert_equal("abbr, acronym {margin-bottom:2em;}", style.rules.first.to_s)
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
  
  def test_nested_declarations
    style = Stylish.generate do
      fieldset :background => {:color => [0, 0, 255], :image => "fieldset.png"}
    end
    
    assert_instance_of(Stylish::Background,
      style.rules.first.declarations.first)
  end
  
  def test_comments
    style = Stylish.generate do
      comment "A glorious comment!"
      comment "An inglorious comment.", "An additional note."
    end
    
    assert_equal(2, style.comments.length)
    assert_equal("A glorious comment!", style.comments[0].header)
    assert_equal("An additional note.", style.comments[1].lines[0])
  end
  
  def test_complex_background
    style = Stylish.generate do
      div :background => {
        :images => ["tl.png", "tr.png", "br.png", "bl.png"],
        :positions => [
          ["left", "top"],
          ["right", "top"],
          ["right", "bottom"],
          ["left", :pos]]}
    end
    
    assert_equal("div {background-image:url('tl.png'), url('tr.png'), " +
     "url('br.png'), url('bl.png'); " +
     "background-position:left top, right top, right bottom, left bottom;}",
     style.to_s({:pos => "bottom"}))
  end
  
  def test_undefined_variables
    style = Stylish.generate do
      body :color => :super_colour
    end
    
    assert_raise Stylish::UndefinedVariable do
      style.to_s({})
    end
  end
end
