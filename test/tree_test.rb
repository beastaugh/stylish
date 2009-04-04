require 'test/unit'
require './lib/stylish'

class TreeTest < Test::Unit::TestCase
  
  def setup
    @tree = Stylish::Tree::Selector.new("body")
  end
  
  def test_appending
    node = Stylish::Tree::Selector.new(".test")
    rule = Stylish::Tree::Rule.new
    node << rule
    @tree << node
    assert_equal(@tree[0], node)
    assert_equal(node[0], rule)
  end
  
  def test_setting
    node = Stylish::Tree::Selector.new(".test")
    rule = Stylish::Tree::Rule.new
    
    @tree[1] = node
    assert_equal(@tree[1], node)
    
    @tree[1] = rule
    assert_equal(@tree[1], rule)
  end
  
  def test_rules_collation
    node = Stylish::Tree::Selector.new(".test")
    rule = Stylish::Tree::Rule.new
    node << rule
    node << rule
    @tree << node
    @tree << node
    
    assert_equal(4, @tree.rules.length)
  end
  
  def test_selector_serialisation
    rule = Stylish::Tree::Rule.new
    node = Stylish::Tree::Selector.new(".test")
    onde = Stylish::Tree::Selector.new(".parent > .child")
    node << rule
    onde << rule
    @tree << node
    @tree << onde
    
    assert_equal("body .test {}\nbody .parent > .child {}", @tree.to_s)
  end
end
