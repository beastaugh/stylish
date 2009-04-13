module Stylish
  
  # Instances of the Image class are used to represent paths to images,
  # generally background images.
  class Image
    include Formattable
    
    attr_accessor :path
    
    # Image instances are serialised to URI values. The path to the image file
    # can be surrounded by either single quotes, double quotes or neither;
    # single quotes are the default in Stylish.
    def initialize(path)
      accept_format(/^url\(\s*('|")?%s\1\s*\)$/, "url('%s')")
      @path = path
    end
    
    # Serialising Image objects to a string produces the URI values seen in
    # background-image declarations, e.g.
    #
    #     image = Image.new("test.png")
    #     image.to_s # => "url('test.png')"
    #
    #     background = Stylish::Background.new(:image => "test.png")
    #     background.to_s # => "background-image:url('test.png');"
    #
    def to_s
      sprintf(@format, path.to_s)
    end
  end
  
end
