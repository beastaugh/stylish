module Stylish
  
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
    attr_reader :color,
                :image,
                :repeat,
                :position,
                :attachment,
                :compressed
    
    PROPERTIES = [
      [:color,      "background-color"],
      [:image,      "background-image"],
      [:repeat,     "background-repeat"],
      [:position,   "background-position"],
      [:attachment, "background-attachment"],
      [:compressed]]
    
    REPEAT_VALUES        = ["repeat", "repeat-x", "repeat-y", "no-repeat"]
    ATTACHMENT_VALUES    = ["scroll", "fixed", "inherit"]
    HORIZONTAL_POSITIONS = ["left", "center", "right"]
    VERTICAL_POSITIONS   = ["top", "center", "bottom"]
    
    # Create a new Background object with the specified properties.
    def initialize(options)
      accept_format(/^\s*%s\s*:\s*%s;\s*$/m, "%s:%s;")
      self.value = options
    end
    
    # Input validation for colours is handled by the Color class, which will
    # raise an ArgumentError if the argument is an invalid colour value.
    def color=(val)
      @color = Color.new(val)
    end
    
    # Set the background image(s). As of CSS3, elements may have multiple
    # background images, so this method attempts to provide a backwards-
    # compatible solution.
    #
    #     background = Background.new :image => "sky.png", :compressed => true
    #     background.to_s # => "background:url('sky.png');"
    #
    #     background.image = ["ball.png", "grass.png"]
    #     background.to_s # => "background:url('ball.png'), url('grass.png');"
    #
    def image=(paths)
      paths  = [paths] if paths.is_a?(String)
      @image = paths.inject([]) {|images, path| images << Image.new(path) }
      
      if @image.length < 2
        @image = @image.first
      else
        def @image.to_s
          join(", ")
        end
      end
    end
    
    # Set the background repeat(s). As of CSS3, the background-repeat property
    # may have multiple values, so this method provides a backwards-compatible
    # solution.
    #
    #     repeating = Background.new :repeat => ["repeat-x", "repeat-y"]
    #     repeating.to_s # => "background-repeat:repeat-x, repeat-y;"
    #
    def repeat=(repeats)
      repeats = [repeats] if repeats.is_a? String
      @repeat = repeats.find_all {|r| REPEAT_VALUES.include? r }
      
      if @repeat.length < 2
        @repeat = @repeat.first
      else
        def @repeat.to_s
          join(", ")
        end
      end
    end
    
    # Only position keywords are currently handled, not percentages or lengths.
    def position=(val)
      xpos, ypos = val.split(/\s+/) << "center"
      if HORIZONTAL_POSITIONS.include?(xpos) && VERTICAL_POSITIONS.include?(ypos)
        @position = [xpos, ypos]
      end
    end
    
    # The background-attachment property takes a limited range of values, so
    # only a value within that range will be accepted.
    def attachment=(val)
      @attachment = val if ATTACHMENT_VALUES.include?(val)
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
      @compressed = val == true || nil
    end
    
    # Override Declaration#name, since it's not compatible with the
    # internals of this class.
    def name
      PROPERTIES.reject {|n, p| p.nil? }.map {|n, p|
        value = self.send(n)
        p.to_s unless value.nil?
      }.compact
    end
    
    # Override Declaration#name=, since it's not compatible with the
    # internals of this class.
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
      
      PROPERTIES.each do |name, property|
        self.send(:"#{name.to_s}=", options[name]) if options[name]
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
    def to_s
      if @compressed
        "background:#{self.value(true).map {|p, v| v }.compact.join(" ")};"
      else
        self.value(true).map {|p, v| sprintf(@format, p, v.to_s) }.join(" ")
      end
    end
  end
  
end