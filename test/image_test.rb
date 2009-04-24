class ImageTest < Test::Unit::TestCase
  
  def setup
    @image = Stylish::Image.new("test.png")
  end
  
  def test_image_path
    assert_equal("test.png", @image.path)
  end
  
  def test_image_serialisation
    assert_equal("url('test.png')", @image.to_s)
  end
end
