require 'test/unit'
require './lib/stylish'

class TreeStylesheetTest < Test::Unit::TestCase
  
  def setup
    @style = Stylish::Tree::Stylesheet.new
    @node  = Stylish::Tree::Selector.new("div")
    @onde  = Stylish::Tree::Selector.new("span")
    @rule  = Stylish::Tree::Rule.new([Stylish::Selector.new("em")],
               Stylish::Declaration.new("font-weight", "bold"))
  end
  
  def test_node_addition
    5.times { @style << @node }
    
    assert_equal(5, @style.nodes.length)
    
    @style.nodes.each do |node|
      assert_instance_of(Stylish::Tree::Selector, node)
    end
  end
  
  def test_root_and_leaf
    assert(@style.root?)
    assert_equal(false, @style.leaf?)
  end
  
  def test_improper_branching
    assert_raise(ArgumentError) do
      @node << @style
    end
  end
  
  def test_serialisation
    [@node, @onde].each {|n| n << @rule; @style << n }
    
    assert_equal("div em {font-weight:bold;}\nspan em {font-weight:bold;}",
      @style.to_s)
  end
end
