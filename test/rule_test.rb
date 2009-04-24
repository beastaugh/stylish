class RuleTest < Test::Unit::TestCase
  
  def setup
    @rule = Stylish::Rule.new([
      Stylish::Selector.new("div .alert, body .error")],
      [Stylish::Declaration.new("font-style", "italic"),
      Stylish::Declaration.new("font-weight", "bold")])
  end
  
  def test_rule_serialisation
    assert_equal("div .alert, body .error " + 
      "{font-style:italic; font-weight:bold;}", @rule.to_s)
  end
  
  def test_selector_listing
    @rule.selectors.each do |selector|
      assert_instance_of(Stylish::Selector, selector)
    end
  end
  
  def test_declaration_listing
    @rule.declarations.each do |declaration|
      assert_instance_of(Stylish::Declaration, declaration)
    end
  end
end
