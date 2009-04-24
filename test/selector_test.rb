require 'test/unit'

class SelectorTest < Test::Unit::TestCase

  def test_to_string
    s = Stylish::Selector.new(".test")
    assert_equal(".test", s.to_s)
    
    s = Stylish::Selector.new(:div)
    assert_equal("div", s.to_s)
  end
end
