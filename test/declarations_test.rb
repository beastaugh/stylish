require 'test/unit'
require './lib/stylish'

class DeclarationsTest < Test::Unit::TestCase
  
  def setup
    @ds = Stylish::Declarations.new
    @ds << Stylish::Declaration.new(:bdcolor, :red)
    @ds << Stylish::Background.new(:color => :blue, :image => "test.png")
  end
  
  def test_join
    assert_equal("border-color:#ff0000; background-color:#0000ff; background-image:test.png;", @ds.join)
  end
  
  def test_to_string
    assert_equal("border-color:#ff0000; background-color:#0000ff; background-image:test.png;", @ds.to_s)
  end
end
