class VariableTest < Test::Unit::TestCase
  
  def setup
    @style = Stylish.generate do
      div :font_weight => :weighty
    end
  end
  
  def test_variable_inclusion    
    assert_instance_of(Stylish::Generate::Variable,
      @style.rules.first.declarations.first.value)
  end
  
  def test_variable_serialisation
    assert_equal("div {font-weight:bold;}",
      @style.to_s({:weighty => "bold"}))
  end
  
  def test_selector_variables
    style = Stylish.generate do
      rule :some_selector, :line_height => 1.5
      
      rule :some_other_selector do
        em :font_weight => "bold"
      end
      
      form do
        rule :third_selector, :text_transform => "uppercase"
      end
    end
    
    assert_equal("body p {line-height:1.5;}\n" +
      "div em {font-weight:bold;}\n" +
      "form legend {text-transform:uppercase;}",
      style.to_s({:some_selector => "body p",
                  :some_other_selector => "div",
                  :third_selector => "legend"}))
  end
  
  def test_color_variables
    style = Stylish.generate do
      body :color => :bright_as_a_button
    end
    
    assert_equal("body {color:#57b5cc;}",
      style.to_s({:bright_as_a_button => "57b5cc"}))
  end
  
  def test_background_variables
    style = Stylish.generate do
      body :background => {:color => :dark, :image => :buttonish}
    end
    
    assert_equal(
      "body {background-color:#000; background-image:url('button.png');}",
      style.to_s({:dark => "000", :buttonish => "button.png"}))
  end
end
