require 'test/unit'
require './lib/stylish'

class BackgroundTest < Test::Unit::TestCase
  
  def setup
    @composite = Stylish::Background.new(:color => "#CCC",
      :image => "images/test.png", :repeat => "no-repeat",
      :position => "left", :attachment => "scroll")
  end
  
  def test_valid_background_colors
    assert_equal("#ccc", @composite.color.to_hex)
    assert_equal("black", Stylish::Background.new(:color => :black).color.to_s)
  end
  
  def test_background_transparencies
    assert_equal([0, 0, 0, 0], Stylish::Background.new(:color => :transparent).color.value)
  end
  
  def test_valid_background_images
    assert_equal("images/test.png", @composite.image)
    assert_equal("background.jpg", Stylish::Background.new(:image => "background.jpg").image)
    File.open(__FILE__) do |file|
      assert_not_nil(Stylish::Background.new(:image => file))
    end
  end
  
  def test_valid_background_repeats
    assert_equal('no-repeat', @composite.repeat)
  end
  
  def test_valid_background_positions
    assert_equal(2, @composite.position.length)
    assert_equal("left", @composite.position[0])
    assert_equal("center", @composite.position[1])
  end
  
  def test_valid_compression
    assert(Stylish::Background.new(:compressed => true))
  end
  
  def test_valid_background_attachments
    assert_equal("scroll", @composite.attachment)
    assert_equal("fixed", Stylish::Background.new(:attachment => "fixed").attachment)
  end
  
  def test_invalid_background_colors
    assert_raise ArgumentError do
      Stylish::Background.new(:color => 'sky-blue')
    end
  end
  
  def test_invalid_image_values
    assert_nil(Stylish::Background.new(:image => []).image)
    assert_nil(Stylish::Background.new(:image => {}).image)
  end
  
  def test_invalid_background_repeats
    assert_nil(Stylish::Background.new(:repeat => 'maxim-gun').repeat)
  end
  
  def test_invalid_background_positions
    assert_nil(Stylish::Background.new(:position => "green ideas").position)
    assert_nil(Stylish::Background.new(:position => "top").position)
  end
  
  def test_invalid_background_attachments
    assert_nil(Stylish::Background.new(:attachment => "static").attachment)
    assert_nil(Stylish::Background.new(:attachment => "unhooked").attachment)
  end
  
  def test_invalid_compression
    assert_nil(Stylish::Background.new(:compressed => "true").compressed)
    assert_nil(Stylish::Background.new(:compressed => "false").compressed)
    assert_nil(Stylish::Background.new(:compressed => nil).compressed)
  end
  
  def test_declaration_property
    assert_equal(["background-color", "background-repeat"],
      Stylish::Background.new(:color => "red", :repeat => "no-repeat").name)
  end
  
  def test_declaration_property_assignment
    background = Stylish::Background.new(:color => "red", :repeat => "no-repeat")
    
    assert_raise(NoMethodError) do
      background.name = "display"
    end
  end
  
  def test_declaration_value
    background = Stylish::Background.new(:color => "red", :repeat => "no-repeat")
    
    assert_equal("no-repeat", background.value[1])
    assert_equal("red", background.value[0].to_s)
  end
  
  def test_declaration_value_assignment
    background = Stylish::Background.new(:color => "red", :repeat => "no-repeat")
    background.value = {:image => "mondrian.jpg"}
    
    assert_equal("mondrian.jpg", background.image)
  end
  
  def test_declaration_value_assignment_errors
    background = Stylish::Background.new(:color => "red", :repeat => "no-repeat")
    
    assert_raise ArgumentError do
      background.value = "mondrian.jpg"
    end
  end
  
  def test_image_declaration_serialisation
    background = Stylish::Background.new(:image => "test.png")
    
    assert_equal("background-image:url('test.png');", background.to_s)
  end
end
