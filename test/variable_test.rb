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
end