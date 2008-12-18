require 'test/unit'
require './lib/stylish'

class SelectorsTest < Test::Unit::TestCase
  
  def setup
    @ss = Stylish::Selectors.new
    
    (1..3).each do |i|
      @ss << Stylish::Selector.new(".test_" + i.to_s)
    end
  end
  
  def test_join
    assert_equal(".test_1, .test_2, .test_3", @ss.join)
  end
  
  def test_to_string
    assert_equal(".test_1, .test_2, .test_3", @ss.to_s)
  end
end
