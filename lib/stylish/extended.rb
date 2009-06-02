module Stylish
  
  # Instances of the Image class are used to represent paths to images,
  # generally background images.
  class Image
    include Formattable
    
    attr_accessor :path
    accept_format(/^url\(\s*('|")?%s\1\s*\)$/, "url('%s')")
    
    # Image instances are serialised to URI values. The path to the image file
    # can be surrounded by either single quotes, double quotes or neither;
    # single quotes are the default in Stylish.
    def initialize(path)
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
      sprintf(self.class.format, path.to_s)
    end
  end
  
  # The Background class is a specialised kind of Declaration, geared towards
  # dealing with the oddities of the background family of declarations, which
  # can exist in both long- and shorthand forms.
  #
  # For example, these longhand background declarations
  #
  #     background-color:  #999;
  #     background-image:  url('bg.png');
  #     background-repeat: repeat-x;
  #
  # could be compressed into a single shorthand declaration
  #
  #     background: #999 url('bg.png') repeat-x;
  #
  # The Background class allows for easy conversion between these forms. It
  # defaults to the longhand versions, allowing rules with stronger selector
  # weighting to only override specific parts of other rules' background
  # declarations.
  class Background < Declaration
    PROPERTIES = [
      [:color,      "background-color"],
      [:image,      "background-image"],
      [:repeat,     "background-repeat"],
      [:position,   "background-position"],
      [:attachment, "background-attachment"],
      [:clip,       "background-clip"],
      [:origin,     "background-origin"],
      [:break,      "background-break"],
      [:compressed]]
    
    REPEAT_VALUES        = ["repeat-x", "repeat-y", "repeat",
                            "space", "round", "no-repeat"]
    ATTACHMENT_VALUES    = ["scroll", "fixed", "local"]
    ORIGIN_VALUES        = ["border-box", "padding-box", "content-box"]
    BREAK_VALUES         = ["bounding-box", "each-box", "continuous"]
    CLIP_VALUES          = ORIGIN_VALUES | ["no-clip"]
    
    PROPERTIES.each do |name, value|
      attr_reader name
    end
    
    # Create a new Background object with the specified properties.
    def initialize(options)
      self.value = options
    end
    
    # Input validation for colours is handled by the Color class, which will
    # raise an ArgumentError if the argument is an invalid colour value.
    #
    #     coloured = Background.new :color => "545454"
    #     coloured.to_s # => "background-color:#545454;"
    #
    def color=(val)
      @color = Color.new(val)
    end
    
    # Set the background image.
    #
    #     background = Background.new :image => "sky.png", :compressed => true
    #     background.to_s # => "background:url('sky.png');"
    #
    def image=(path)
      @image = Image.new(path)
    end
    
    # As of CSS3, elements may have multiple background images.
    #
    #     background.images = ["ball.png", "grass.png"]
    #     background.to_s # => "background:url('ball.png'), url('grass.png');"
    #
    def images=(paths)
      @image = paths.inject(PropertyBundle.new) do |is, i|
        is << Image.new(i)
      end
    end
    
    # Set the background repeat.
    #
    #     nonrepeating = Background.new :repeat => "no-repeat"
    #     nonrepeating.to_s # => "background-repeat:no-repeat;"
    #
    def repeat=(repeat)
      @repeat = repeat if REPEAT_VALUES.include? repeat
    end
    
    # As of CSS3, the background-repeat property may have multiple values.
    #
    #     repeating = Background.new :repeats => ["repeat-x", "repeat-y"]
    #     repeating.to_s # => "background-repeat:repeat-x, repeat-y;"
    #
    def repeats=(repeats)
      @repeat = repeats.inject(PropertyBundle.new) do |rs, r|
        rs << r if REPEAT_VALUES.include? r
        rs
      end
    end
    
    # Positions have an x and a y value, and are handled by a specialised
    # Position class. They should be passed an array of two values, e.g.
    #
    #     positioned = Background.new :position => ["100%", 0]
    #     positioned.to_s # => "background-position:100% 0;"
    #
    # See the documentation for the Position class for further details on
    # permitted position types.
    def position=(position)
      @position = Position.new(position[0], position[1])
    end
    
    # As of CSS3, elements may have multiple background images, and
    # consequently they will need to be separately positioned as well.
    #
    #     p = Background.new :positions => [["left", "top"], ["right", "top"]]
    #     p.to_s # => "background-position:left top, right top;"
    #
    def positions=(positions)
      @position = positions.inject(PropertyBundle.new) do |ps, p|
        ps << Position.new(p[0], p[1])
      end
    end
    
    # The background-attachment property takes a limited range of values, so
    # only a value within that range will be accepted.
    #
    #     attached = Background.new :attachment => "fixed"
    #     attached.to_s # => "background-attachment:fixed;"
    #
    def attachment=(attachment)
      @attachment = attachment if ATTACHMENT_VALUES.include? attachment
    end
    
    # As of CSS3 elements may have multiple background-attachment values.
    #
    #     atts = Background.new :attachments => ["fixed", "scroll"]
    #     atts.to_s # => "background-attachment:fixed, scroll;"
    #
    def attachments=(attachments)
      @attachment = attachments.inject(PropertyBundle.new) do |as, a|
        as << a if ATTACHMENT_VALUES.include? a
        as
      end
    end
    
    # The background-clip property specifies the background painting area.
    #
    #     clipped = Background.new :clip => "no-clip"
    #     clipped.to_s # => "background-clip:no-clip;"
    #
    def clip=(clip)
      @clip = clip if CLIP_VALUES.include? clip
    end
    
    # The background-clip property is a CSS3 property and can take multiple
    # values.
    #
    #     clipper = Background.new :clips => ["border-box", "padding-box"]
    #     clipper.to_s # => "background-clip:border-box, padding-box;"
    #
    def clips=(clips)
      @clip = clips.inject(PropertyBundle.new) do |cs, c|
        cs << c if CLIP_VALUES.include? c
        cs
      end
    end
    
    # The background-origin property specifies the background positioning area.
    #
    #     original = Background.new :origin => "content-box"
    #     original.to_s # => "background-origin:content-box;"
    #
    def origin=(origin)
      @origin = origin if ORIGIN_VALUES.include? origin
    end
    
    # The background-origin property is a CSS3 property and can take multiple
    # values.
    #
    #     origs = Background.new :origin => ["padding-box", "content-box"]
    #     origs.to_s # => "background-origin:padding-box, content-box;"
    #
    def origins=(origins)
      @origin = origins.inject(PropertyBundle.new) do |os, o|
        os << o if ORIGIN_VALUES.include? o
        os
      end
    end
    
    # The background-break property, defined in CSS3, specifies how the
    # background positioning area is derived when an element is broken into
    # multiple boxes.
    #
    #     broken = Background.new :break => "bounding-box"
    #     broken.to_s # => "background-break:bounding-box;"
    #
    def break=(value)
      @break = value if BREAK_VALUES.include? value
    end
    
    # Set this to true to generate a shorthand declaration, e.g.
    #
    #     background:#ccc url('bg.png') no-repeat 0 0;
    #
    # As opposed to the longhand version:
    #
    #     background-color:#ccc; background-image:url('bg.png');
    #     background-repeat:no-repeat; background-position:0 0;
    #
    def compressed=(val)
      @compressed = val == true
    end
    
    # Override Declaration#name, since it's not compatible with the internals
    # of this class.
    def name
      PROPERTIES.reject {|n, p| p.nil? }.map {|n, p|
        value = self.send(n)
        p.to_s unless value.nil?
      }.compact
    end
    
    # Override Declaration#name=, since it's not compatible with the internals
    # of this class.
    def name=(val)
      raise NoMethodError, "name= is not defined for Background."
    end
    
    # Override Declaration#value, since it's not compatible with the internals
    # of this class.
    def value(name_and_value = false)
      PROPERTIES.reject {|n, p| p.nil? }.map {|n, p|
        value = self.send(n)
        next if value.nil?
        name_and_value ? [p.to_s, value] : value
      }.compact
    end
    
    # Override Declaration#value=, since it's not compatible with the internals
    # of this class.
    def value=(options)
      unless options.is_a? Hash
        raise ArgumentError, "Argument must be a hash of background properties"
      end
      
      PROPERTIES.each do |name, value|
        plural = (name.to_s + "s").to_sym
        self.send(:"#{name.to_s}=", options[name]) if options[name]
        self.send(:"#{name.to_s}s=", options[plural]) if options[plural]
      end
    end
    
    # Generate a string representation of a Background instance.
    #
    # There are two kinds of representation, each of which have slightly
    # different CSS semantics. If compressed is set to true, this method will
    # produce a shorthand CSS declaration such as the following:
    #
    #     background: #fff url('bg.png') no-repeat 50% 0;
    #
    # Otherwise it will produce an unordered list of individual background
    # declarations.
    def to_s(symbols = {}, scope = "")
      if @compressed
        "background:#{self.value(true).map {|p, v| v }.compact.join(" ")};"
      else
        self.value(true).map {|p, v|
          sprintf(self.class.format, p, v.to_s)
        }.join(Declarations.format)
      end
    end
  end
  
end
