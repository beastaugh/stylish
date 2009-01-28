module Stylish #:nodoc:
  
  # The Color class is intended to eventually implement the entirety of the
  # {CSS Color Module Level 3}[link:http://www.w3.org/TR/css3-color/].
  #
  # Color values are stored internally in an RGBA format, consisting of three
  # integer values between 0 and 255 for red, green and blue, and an opacity
  # value of between 0 and 1. This internal representation is then converted
  # to the desired output format on demand. Serialising the color to a string
  # will, by default, use the output format that matches the input format.
  #
  # E.g., if the input format is a hexadecimal string, the #to_s method will
  # call the #to_hex method.
  #
  #   color = Color.new("#fff")
  #   color.to_s # => "#fff"
  #
  class Color
    attr_reader :type, :opacity
    
    # Regular expressions matching an integer in the RGB color range; only an
    # RGB integer; a hexadecimal representation of an RGB color; a rgb()
    # representation of an RGB color; and an rgba() representation of an RGBA
    # color.
    OPACITY    = /([0-1]|0\.\d+)/
    RGB_INT    = /(\d{1,2}|[1-2][0-5]{2})/
    HSL_INT    = /(\d{1,2}|[1-2]\d{2}|3([0-5]\d|60))/
    HEX_COLOR  = /^#?([\da-fA-F]{3}){1,2}$/
    RGB_COLOR  = /rgb\(\s*((#{RGB_INT}|#{PCT}),\s*){2}(#{RGB_INT}|#{PCT})\s*\)/
    RGBA_COLOR = /rgba\(\s*((#{RGB_INT}|#{PCT}),\s*){3}#{OPACITY}\s*\)/
    HSL_COLOR  = /hsl\(\s*((#{HSL_INT}|#{PCT}),\s*){2}(#{HSL_INT}|#{PCT})\s*\)/
    HSLA_COLOR = /hsla\(\s*((#{HSL_INT}|#{PCT}),\s*){3}(#{OPACITY})\s*\)/
    
    # Colors can be of several types: keywords, hexadecimal strings, RGB and
    # RGBA formats. The type of the color is set on initialisation, so that
    # the output format matches the input format.
    TYPES = [:inherit, :keyword, :hex, :rgb, :rgba, :hsl, :rgba]
    
    KEYWORDS = {
      # HTML4 color keywords.
      #
      # * {HTML4 color keywords}[http://www.w3.org/TR/css3-color/#html4]
      :aqua    => [0,   255, 255, nil], # => #0ff
      :black   => [0,   0,   0,   nil], # => #000
      :blue    => [0,   0,   255, nil], # => #00f
      :fuchsia => [255, 0,   255, nil], # => #f0f
      :gray    => [128, 128, 128, nil], # => #808080
      :green   => [0,   128, 0,   nil], # => #008000
      :lime    => [0,   255, 0,   nil], # => #00ff00
      :maroon  => [128, 0,   0,   nil], # => #800000
      :navy    => [0,   0,   128, nil], # => #000080
      :olive   => [128, 128, 0,   nil], # => #808000
      :orange  => [255, 165, 0,   nil], # => #ffA500
      :purple  => [128, 0,   128, nil], # => #800080
      :red     => [255, 0,   0,   nil], # => #f00
      :silver  => [192, 192, 192, nil], # => #c0c0c0
      :teal    => [0,   128, 128, nil], # => #008080
      :white   => [255, 255, 255, nil], # => #fff
      :yellow  => [255, 255, 0,   nil], # => #ffff00
      
      # SVG color keywords, also known as X11 colors. The lists linked below
      # also include the HTML4 color keywords listed above.
      #
      # * {SVG colors}[http://www.w3.org/TR/SVG/types.html#ColorKeywords]
      # * {X11 colors}[http://msdn.microsoft.com/en-us/library/aa905747.aspx]
      :aliceblue            => [240, 248, 255, nil], # => #f0f8ff
      :antiquewhite         => [250, 235, 215, nil], # => #faebd7
      :aquamarine           => [127, 255, 212, nil], # => #7fffd4
      :azure                => [240, 255, 255, nil], # => #f0ffff
      :beige                => [245, 245, 220, nil], # => #f5f5dc
      :bisque               => [255, 228, 196, nil], # => #ffe4c4
      :blanchedalmond       => [255, 235, 205, nil], # => #ffebcd
      :blueviolet           => [138, 43,  226, nil], # => #8a2be2
      :brown                => [165, 42,  42,  nil], # => #a52a2a
      :burlywood            => [222, 184, 135, nil], # => #deb887
      :cadetblue            => [95,  158, 160, nil], # => #5f9ea0
      :chartreuse           => [127, 255, 0,   nil], # => #7fff00
      :chocolate            => [210, 105, 30,  nil], # => #d2691e
      :coral                => [255, 127, 80,  nil], # => #ff7f50
      :cornflowerblue       => [100, 149, 237, nil], # => #6495ed
      :cornsilk             => [255, 248, 220, nil], # => #fff8dc
      :crimson              => [220, 20,  60,  nil], # => #dc143c
      :cyan                 => [0,   255, 255, nil], # => #00ffff
      :darkblue             => [0,   0,   139, nil], # => #00008b
      :darkcyan             => [0,   139, 139, nil], # => #008b8b
      :darkgoldenrod        => [184, 134, 11,  nil], # => #b8860b
      :darkgray             => [169, 169, 169, nil], # => #a9a9a9
      :darkgreen            => [0,   100, 0,   nil], # => #006400
      :darkgrey             => [169, 169, 169, nil], # => #a9a9a9
      :darkkhaki            => [189, 183, 107, nil], # => #bdb76b
      :darkmagenta          => [139, 0,   139, nil], # => #8b008b
      :darkolivegreen       => [85,  107, 47,  nil], # => #556b2f
      :darkorange           => [255, 140, 0,   nil], # => #ff8c00
      :darkorchid           => [153, 50,  204, nil], # => #9932cc
      :darkred              => [139, 0,   0,   nil], # => #8b0000
      :darksalmon           => [233, 150, 122, nil], # => #e9967a
      :darkseagreen         => [143, 188, 143, nil], # => #8fbc8f
      :darkslateblue        => [72,  61,  139, nil], # => #483d8b
      :darkslategray        => [47,  79,  79,  nil], # => #2f4f4f
      :darkslategrey        => [47,  79,  79,  nil], # => #2f4f4f
      :darkturquoise        => [0,   206, 209, nil], # => #00ced1
      :darkviolet           => [148, 0,   211, nil], # => #9400d3
      :deeppink             => [255, 20,  147, nil], # => #ff1493
      :deepskyblue          => [0,   191, 255, nil], # => #00bfff
      :dimgray              => [105, 105, 105, nil], # => #696969
      :dimgrey              => [105, 105, 105, nil], # => #696969
      :dodgerblue           => [30,  144, 255, nil], # => #1e90ff
      :firebrick            => [178, 34,  34,  nil], # => #b22222
      :floralwhite          => [255, 250, 240, nil], # => #fffaf0
      :forestgreen          => [34,  139, 34,  nil], # => #228b22
      :gainsboro            => [220, 220, 220, nil], # => #dcdcdc
      :ghostwhite           => [248, 248, 255, nil], # => #f8f8ff
      :gold                 => [255, 215, 0,   nil], # => #ffd700
      :goldenrod            => [218, 165, 32,  nil], # => #daa520
      :greenyellow          => [173, 255, 47,  nil], # => #adff2f
      :grey                 => [128, 128, 128, nil], # => #808080
      :honeydew             => [240, 255, 240, nil], # => #f0fff0
      :hotpink              => [255, 105, 180, nil], # => #ff69b4
      :indianred            => [205, 92,  92,  nil], # => #cd5c5c
      :indigo               => [75,  0,   130, nil], # => #4b0082
      :ivory                => [255, 255, 240, nil], # => #fffff0
      :khaki                => [240, 230, 140, nil], # => #f0e68c
      :lavender             => [230, 230, 250, nil], # => #e6e6fa
      :lavenderblush        => [255, 240, 245, nil], # => #fff0f5
      :lawngreen            => [124, 252, 0,   nil], # => #7cfc00
      :lemonchiffon         => [255, 250, 205, nil], # => #fffacd
      :lightblue            => [173, 216, 230, nil], # => #add8e6
      :lightcoral           => [240, 128, 128, nil], # => #f08080
      :lightcyan            => [224, 255, 255, nil], # => #e0ffff
      :lightgoldenrodyellow => [250, 250, 210, nil], # => #fafad2
      :lightgray            => [211, 211, 211, nil], # => #d3d3d3
      :lightgreen           => [144, 238, 144, nil], # => #90ee90
      :lightgrey            => [211, 211, 211, nil], # => #d3d3d3
      :lightpink            => [255, 182, 193, nil], # => #ffb6c1
      :lightsalmon          => [255, 160, 122, nil], # => #ffa07a
      :lightseagreen        => [32,  178, 170, nil], # => #20b2aa
      :lightskyblue         => [135, 206, 250, nil], # => #87cefa
      :lightslategray       => [119, 136, 153, nil], # => #778899
      :lightslategrey       => [119, 136, 153, nil], # => #778899
      :lightsteelblue       => [176, 196, 222, nil], # => #b0c4de
      :lightyellow          => [255, 255, 224, nil], # => #ffffe0
      :limegreen            => [50,  205, 50,  nil], # => #32cd32
      :linen                => [250, 240, 230, nil], # => #faf0e6
      :magenta              => [255, 0,   255, nil], # => #ff00ff
      :mediumaquamarine     => [102, 205, 170, nil], # => #66cdaa
      :mediumblue           => [0,   0,   205, nil], # => #0000cd
      :mediumorchid         => [186, 85,  211, nil], # => #ba55d3
      :mediumpurple         => [147, 112, 219, nil], # => #9370db
      :mediumseagreen       => [60,  179, 113, nil], # => #3cb371
      :mediumslateblue      => [123, 104, 238, nil], # => #7b68ee
      :mediumspringgreen    => [0,   250, 154, nil], # => #00fa9a
      :mediumturquoise      => [72,  209, 204, nil], # => #48d1cc
      :mediumvioletred      => [199, 21,  133, nil], # => #c71585
      :midnightblue         => [25,  25,  112, nil], # => #191970
      :mintcream            => [245, 255, 250, nil], # => #f5fffa
      :mistyrose            => [255, 228, 225, nil], # => #ffe4e1
      :moccasin             => [255, 228, 181, nil], # => #ffe4b5
      :navajowhite          => [255, 222, 173, nil], # => #ffdead
      :oldlace              => [253, 245, 230, nil], # => #fdf5e6
      :olivedrab            => [107, 142, 35,  nil], # => #6b8e23
      :orangered            => [255, 69,  0,   nil], # => #ff4500
      :orchid               => [218, 112, 214, nil], # => #da70d6
      :palegoldenrod        => [238, 232, 170, nil], # => #eee8aa
      :palegreen            => [152, 251, 152, nil], # => #98fb98
      :paleturquoise        => [175, 238, 238, nil], # => #afeeee
      :palevioletred        => [219, 112, 147, nil], # => #db7093
      :papayawhip           => [255, 239, 213, nil], # => #ffefd5
      :peachpuff            => [255, 218, 185, nil], # => #ffdab9
      :peru                 => [205, 133, 63,  nil], # => #cd853f
      :pink                 => [255, 192, 203, nil], # => #ffc0cb
      :plum                 => [221, 160, 221, nil], # => #dda0dd
      :powderblue           => [176, 224, 230, nil], # => #b0e0e6
      :rosybrown            => [188, 143, 143, nil], # => #bc8f8f
      :royalblue            => [65,  105, 225, nil], # => #4169e1
      :saddlebrown          => [139, 69,  19,  nil], # => #8b4513
      :salmon               => [250, 128, 114, nil], # => #fa8072
      :sandybrown           => [244, 164, 96,  nil], # => #f4a460
      :seagreen             => [46,  139, 87,  nil], # => #2e8b57
      :seashell             => [255, 245, 238, nil], # => #fff5ee
      :sienna               => [160, 82,  45,  nil], # => #a0522d
      :skyblue              => [135, 206, 235, nil], # => #87ceeb
      :slateblue            => [106, 90,  205, nil], # => #6a5acd
      :slategray            => [112, 128, 144, nil], # => #708090
      :slategrey            => [112, 128, 144, nil], # => #708090
      :snow                 => [255, 250, 250, nil], # => #fffafa
      :springgreen          => [0,   255, 127, nil], # => #00ff7f
      :steelblue            => [70,  130, 180, nil], # => #4682b4
      :tan                  => [210, 180, 140, nil], # => #d2b48c
      :thistle              => [216, 191, 216, nil], # => #d8bfd8
      :tomato               => [255, 99,  71,  nil], # => #ff6347
      :turquoise            => [64,  224, 208, nil], # => #40e0d0
      :violet               => [238, 130, 238, nil], # => #ee82ee
      :wheat                => [245, 222, 179, nil], # => #f5deb3
      :whitesmoke           => [245, 245, 245, nil], # => #f5f5f5
      :yellowgreen          => [154, 205, 50,  nil], # => #9acd32
      
      # The 'transparent' keyword, added to the CSS color spec in CSS3.
      #
      # * {'Transparent' keyword}[http://www.w3.org/TR/css3-color/#transparent]
      :transparent => [0, 0, 0, 0]} # => transparent
    
    # Generate attribute accessors for each RGB color value. They can then be
    # used for reading and writing specific components of the color.
    #
    #   color = Color.new
    #   color.red = 64
    #   color.red # => 64
    #   color.red = 512
    #   color.red # => 64
    #
    [:red, :green, :blue].each do |color|
      reader = color
      writer = :"#{color}="
      color = :"@#{color.to_s}"
      
      unless self.respond_to?(reader)
        self.send(:define_method, reader) do
          instance_variable_get(color)
        end
      end
      
      unless self.respond_to?(writer)
        self.send(:define_method, writer) do |value|
          if (0..255).include?(value)
            instance_variable_set(color, value)
          end
        end
      end
    end
    
    # Set the initial value of the color to the provided parameter.
    def initialize(value)
      self.value = value
    end
    
    # Attribute reader for the color's value.
    def value
      return "inherit" if @type == :inherit
      
      [@red, @green, @blue, @opacity]
    end
    
    # Attribute writer for the color's value. Uses the ColorStringParser inner
    # class to parse string values, and contains other logic to handle arrays.
    def value=(value)
      if value.is_a?(String) || value.is_a?(Symbol)
        parser = ColorStringParser.new
        @type, @red, @green, @blue, @opacity = parser.parse(value)
        return unless @type.nil?
      elsif value.is_a?(Array) && (3..4).include?(value.length)
        rgb = value[0..2].inject([]) do |rgb, v|
          if v.is_a?(Integer) || v.is_a?(Float)
            rgb << v
          elsif v =~ /^#{RGB_INT}$/
            rgb << v.to_i
          elsif v =~ PERCENTAGE
            rgb << (v.chop.to_f * 256 / 100).round
          end
          
          rgb
        end
        
        if rgb.length == 3
          if value.length == 3
            @red, @green, @blue, @opacity = rgb << nil
            @type = :rgb and return
          elsif value.length == 4 and value[3] =~ /^([0-1]|0\.\d+)$/
            @red, @green, @blue, @opacity = rgb << value[3].to_f
            @type = :rgba and return
          end
        end
      end
      
      raise ArgumentError,
        "#{value.inspect} is not a valid keyword, hex or RGB color value."
    end
    
    # Set the opacity of the color to a value from 0 to 1.
    #
    #   color = Color.new([255, 0, 255, 0])
    #   color.opacity = 1
    #   color.opacity # => 1
    #   color.opacity = 1.5
    #   color.opacity # => 1
    #   color.opacity = 0.5
    #   color.opacity # => 0.5
    #
    def opacity=(value)
      return unless value.is_a?(Integer) || value.is_a?(Float)
      return if value < 0 || value > 1
      
      @opacity = value
    end
    
    # Returns a color keyword string if the RGB value of the color is equal to
    # one of the color keywords defined in the CSS specification.
    #
    #   color = Color.new("#fff")
    #   color.to_keyword # => "white"
    #
    #   clear = Color.new([0, 0, 0, 0])
    #   color.to_keyword # => "transparent"
    #
    def to_keyword
      KEYWORDS.index(self.value).to_s
    end
    
    # Returns a string representation of the color's RGB color value.
    #
    #   color = Color.new("#000")
    #   color.to_rgb # => "rgb(0, 0, 0)"
    #
    # Neither #to_rgb nor #to_rgba outputs percentages, only numeric values.
    # Keeping track of which values were percentages and which were numeric
    # internally would be excessively complex, and outputs as they stand
    # are both consistent and more accurate than percentages would be.
    def to_rgb
      "rgb(#{self.value[0..2] * ", "})"
    end
    
    # Returns a string representation of the color's RGBA color value.
    #
    #   color = Color.new(["100%", 255, 0, 0.5])
    #   color.to_rgba # => "rgba(255, 255, 0, 0.5)"
    #
    def to_rgba
      value = self.value
      value[3] = 1 if self.opacity.nil?
      "rgba(#{value * ", "})"
    end
    
    # Returns a hexadecimal string representation of a color's RGB color value.
    #
    #   color = Color.new([255, 255, 0])
    #   color.to_hex # => "#ff0"
    #   color.value = [184, 78, 20]
    #   color.to_hex # => "#b84e14"
    #
    # RGBA values have an opacity value which is not convertible to a six-
    # character hexadecimal string, so this information is stripped and a
    # conventional RGB value is then converted to hex.
    #
    # All values will be converted, if possible, from six-digit to three-digit
    # notation, replacing replicated digits with single values.
    #
    #     #ffffff => #fff
    #     #ffbb00 => #fb0
    #
    # Inherit and transparent have no hex equivalents, so the method simply
    # returns nil.
    def to_hex
      return if self.type == :inherit || self.value == [0, 0, 0, 0]
      
      hexcolor = self.value[0..2].inject("") do |hex, num|
        str = num.to_s(16)
        str = "0" + str if str.length < 2
        hex << str
      end
      
      "#" + self.class.compress_hex(hexcolor)
    end
    
    def to_hsl
    end
    
    def to_hsla
    end
    
    # Returns a string representation of the color's value. The output format
    # depends on the type of the color object: if it's set to hex, the output
    # format will be a hexadecimal representation of the color value, etc.
    #
    #   color = Color.new("#000")
    #   color.to_s # => "#000"
    #   color.type = :rgb
    #   color.to_s # => "rgb(0, 0, 0)"
    #
    def to_s
      return "inherit" if @type == :inherit
      
      self.send(:"to_#{self.type.to_s}")
    end
    
    private
    
    # Compress six-character hexadecimal color values to abbreviated, three-
    # character ones.
    #
    #   Color.compress_hex("ff00ff") # => "f0f"
    #
    def self.compress_hex(hexvalue)
      return hexvalue unless hexvalue.length % 2 == 0
      
      compressed = hexvalue.scan(/[\da-fA-F]{2}/).inject("") do |hex, str|
        hex += str[0,1] == str[1,2] ? str[0,1] : str
      end
      
      compressed.length == hexvalue.length / 2 ? compressed : hexvalue
    end
    
    # A small parser for string color values.
    class ColorStringParser
      attr_reader :type
      
      # Parse a string input, returning an array of numbers corresponding to
      # red, green, blue, and the opacity value.
      def parse(value)
        value = value.to_s.downcase
        key = value.to_sym
        
        return [:inherit, nil, nil, nil, nil] if value == "inherit"
        
        return [:keyword].concat(KEYWORDS[key]) if KEYWORDS.has_key?(key)
        
        if value =~ HEX_COLOR
          return [:hex].concat(self.class.convert_hex(value))
        end
        
        if value =~ RGB_COLOR
          return [:rgb].concat(self.class.convert_rgb(value))
        end
        
        if value =~ RGBA_COLOR
          return [:rgba].concat(self.class.convert_rgba(value))
        end
        
        if value =~ HSL_COLOR
          return [:hsl].concat(self.class.convert_hsl(value))
        end
        
        if value =~ HSLA_COLOR
          return [:hsla].concat(self.class.convert_hsla(value))
        end
        
        nil
      end
      
      private
      
      # Convert a hexadecimal representation of an RGB color to an array of
      # base 10 integers.
      def self.convert_hex(hexcolor)
        hexcolor.gsub!(/[^a-f\d]/, "")
        hexcolor.gsub!(/(.)/, '\1' * 2) if hexcolor.length == 3
        hexcolor.scan(/.{2}/).map {|num| num.hex } << nil
      end
      
      # Convert an rgb()-formatted representation of an RGB color to an array
      # of base 10 integers.
      def self.convert_rgb(rgbcolor)
        rgbcolor.sub(/^\s*rgb\(\s*/, "").
        sub(/\s*\)\s*$/, "").
        split(/\s*,\s*/).
        map {|value|
          if value =~ /^#{RGB_INT}$/
            value.to_i
          else
            (value.chop.to_f * 255 / 100).round
          end
        } << nil
      end
      
      # Convert an rgba()-formatted representation of an RGB color to an array
      # of three base 10 integers corresponding to red, green and blue, and a
      # float representing the opacity.
      def self.convert_rgba(rgbacolor)
        rgbacolor.sub(/rgba\(\s*/, "").
        sub(/\s*\)$/, "").
        split(/\s*,\s*/).
        map do |value|
          if value =~ /^#{RGB_INT}$/
            value.to_i
          elsif value =~ PERCENTAGE
            (value.chop.to_f * 255 / 100).round
          else
            value.to_f
          end
        end
      end
      
      def self.convert_hsl(hslcolor)
        self.hsla_to_rgba(hslcolor.
        sub(/hsl\(\s*/, "").
        sub(/\s*\)$/, "").
        split(/\s*,\s*/).
        map {|value|
          if value =~ /^#{HSL_INT}/
            value.to_i
          else
            (value.chop.to_f * 360 / 100).round
          end
        } << nil)
      end
      
      def self.convert_hsla(hslacolor)
        self.hsla_to_rgba(hslacolor.
        sub(/hsla\(\s*/, "").
        sub(/\s*\)$/).
        split(/\s*,\s*/).
        map {|value|
          if value =~ /^#{HSL_INT}$/
            value.to_i
          elsif value =~ PERCENTAGE
            (value.chop.to_f * 360 / 100).round
          else
            value.to_f
          end
        })
      end
      
      def self.hsla_to_rgba(hslacolor)
        opacity = hslacolor.pop
        rgbacolor = Array.new(3)
        
        return rgbacolor.fill(hslacolor[2]) << opacity if hslacolor.first == 0
        
        rgbacolor << opacity
      end
    end
  end
  
end
