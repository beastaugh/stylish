require 'test/unit'
require './lib/stylish'

class DeclarationTest < Test::Unit::TestCase
  
  def test_shorthands
    dec = Stylish::Declaration.new(:bgcolor, "#fff")
    assert_equal("background-color", dec.property)
    
    dec.property = :bdcolor
    assert_equal("border-color", dec.property)
  end
end
