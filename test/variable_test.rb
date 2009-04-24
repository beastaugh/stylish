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
    end
    
    assert_equal("body p {line-height:1.5;}",
      style.to_s({:some_selector => "body p"}))
  end
  
  def test_color_variables
    style = Stylish.generate do
      body :color => :bright_as_a_button
    end
    
    assert_equal("body {color:#57b5cc;}",
      style.to_s({:bright_as_a_button => "57b5cc"}))
  end
end
