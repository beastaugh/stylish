class BackgroundTest < Test::Unit::TestCase
  
  def setup
    @composite = Stylish::Background.new(:color => "#CCC",
      :image => "images/test.png", :repeat => "no-repeat",
      :position => ["left", "top"], :attachment => "scroll")
  end
  
  def teardown
    Stylish::Declarations.format = " "
  end
  
  def test_valid_background_colors
    assert_equal("#ccc", @composite.color.to_hex)
    assert_equal("black", Stylish::Background.new(:color => "black").color.to_s)
  end
  
  def test_background_transparencies
    assert_equal([0, 0, 0, 0], Stylish::Background.new(:color => "transparent").color.value)
  end
  
  def test_valid_background_images
    assert_equal("images/test.png", @composite.image.path)
    assert_equal("background.jpg",
      Stylish::Background.new(:image => "background.jpg").image.path)
  end
  
  def test_multiple_background_images
    bg = Stylish::Background.new :images =>
           ["flower.png", "ball.png", "grass.png"]
    
    assert_equal(3, bg.image.length)
    assert_equal("background-image:" +
      "url('flower.png'), url('ball.png'), url('grass.png');", bg.to_s)
  end
  
  def test_valid_background_repeats
    assert_equal('no-repeat', @composite.repeat)
  end
  
  def test_multiple_background_repeats
    bg = Stylish::Background.new :repeats => ["repeat-x", "repeat-y"]
    
    assert_equal(2, bg.repeat.length)
    assert_equal("background-repeat:repeat-x, repeat-y;", bg.to_s)
  end
  
  def test_valid_background_positions
    assert_equal("left", @composite.position.x)
    assert_equal("top", @composite.position.y)
  end
  
  def test_position_serialisation
    positioned = Stylish::Background.new({:position => ["100%", 0]})
    assert_equal("background-position:100% 0;", positioned.to_s)
  end
  
  def test_compression
    assert(Stylish::Background.new(:compressed => true))
    assert_equal(false, Stylish::Background.new(:compressed => "true").compressed)
    assert_equal(false, Stylish::Background.new(:compressed => "false").compressed)
    assert_nil(Stylish::Background.new(:compressed => nil).compressed)
  end
  
  def test_valid_background_attachments
    assert_equal("scroll", @composite.attachment)
    assert_equal("fixed",
      Stylish::Background.new(:attachment => "fixed").attachment)
  end
  
  def test_multiple_attachments
    glued = Stylish::Background.new :attachments => ["local", "fixed"]
    
    assert_equal(2, glued.attachment.length)
    assert_equal("background-attachment:local, fixed;", glued.to_s)
  end
  
  def test_invalid_background_colors
    assert_raise ArgumentError do
      Stylish::Background.new(:color => "sky-blue")
    end
  end
  
  def test_clips
    clipper = Stylish::Background.new :clips => ["no-clip", "content-box"]
    
    assert_equal(2, clipper.clip.length)
    assert_equal("background-clip:no-clip, content-box;", clipper.to_s)
  end
  
  def test_origins
    original = Stylish::Background.new :origins => ["border-box", "padding-box"]
    
    assert_equal(2, original.origin.length)
    assert_equal("background-origin:border-box, padding-box;", original.to_s)
  end
  
  def test_breaks
    broken = Stylish::Background.new :break => "bounding-box"
    
    assert_equal("background-break:bounding-box;", broken.to_s)
  end
  
  def test_invalid_background_repeats
    assert_nil(Stylish::Background.new(:repeat => 'maxim-gun').repeat)
  end
  
  def test_invalid_background_attachments
    assert_nil(Stylish::Background.new(:attachment => "static").attachment)
    assert_nil(Stylish::Background.new(:attachment => "unhooked").attachment)
  end
  
  def test_declaration_property
    assert_equal(["background-color", "background-repeat"],
      Stylish::Background.new(:color => "red", :repeat => "no-repeat").name)
  end
  
  def test_declaration_property_assignment
    background = Stylish::Background.new(:color => "red",
      :repeat => "no-repeat")
    
    assert_raise(NoMethodError) do
      background.name = "display"
    end
  end
  
  def test_declaration_value
    background = Stylish::Background.new(:color => "red",
      :repeat => "no-repeat")
    
    assert_equal("no-repeat", background.value[1])
    assert_equal("red", background.value[0].to_s)
  end
  
  def test_declaration_value_assignment
    background = Stylish::Background.new(:color => "red")
    background.value = {:image => "mondrian.jpg"}
    
    assert_equal("mondrian.jpg", background.image.path)
  end
  
  def test_declaration_value_assignment_errors
    background = Stylish::Background.new(:color => "red")
    
    assert_raise ArgumentError do
      background.value = "mondrian.jpg"
    end
  end
  
  def test_image_declaration_serialisation
    background = Stylish::Background.new(:image => "test.png")
    
    assert_equal("background-image:url('test.png');", background.to_s)
  end
  
  def test_declaration_formatting_changes
    Stylish::Declarations.format = "\n"
    
    assert_equal("background-color:#ccc;\n" +
                 "background-image:url('images/test.png');\n" +
                 "background-repeat:no-repeat;\n" +
                 "background-position:left top;\n" +
                 "background-attachment:scroll;", @composite.to_s)
  end
end
