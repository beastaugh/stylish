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
    RINT             = /(\d{1,2}|[1-2][0-5]{2})/
    RGB_INTEGER      = /^#{RINT}$/
    VALID_HEX_COLOR  = /^#?([\da-fA-F]{3}){1,2}$/
    VALID_RGB_COLOR  = /\s*rgb\(((#{RINT}|#{PCT}),\s*){2}(#{RINT}|#{PCT})\s*\)\s*/
    VALID_RGBA_COLOR = /\s*rgba\(((#{RINT}|#{PCT}),\s*){3}([0-1]|0\.\d+)\s*\)\s*/
    
    # Colors can be of several types: keywords, hexadecimal strings, RGB and
    # RGBA formats. The type of the color is set on initialisation, so that
    # the output format matches the input format.
    TYPES = [:inherit, :keyword, :hex, :rgb, :rgba]
    
    KEYWORDS = {
      :aqua        => [0,   255, 255, nil], # => #00ffff
      :black       => [0,   0,   0,   nil], # => #000
      :blue        => [0,   0,   255, nil], # => #0000ff
      :fuchsia     => [255, 0,   255, nil], # => #ff00ff
      :gray        => [128, 128, 128, nil], # => #808080
      :green       => [0,   128, 0,   nil], # => #008000
      :lime        => [0,   255, 0,   nil], # => #00ff00
      :maroon      => [128, 0,   0,   nil], # => #800000
      :navy        => [0,   0,   128, nil], # => #000080
      :olive       => [128, 128, 0,   nil], # => #808000
      :orange      => [255, 165, 0,   nil], # => #ffA500
      :purple      => [128, 0,   128, nil], # => #800080
      :red         => [255, 0,   0,   nil], # => #ff0000
      :silver      => [192, 192, 192, nil], # => #c0c0c0
      :teal        => [0,   128, 128, nil], # => #008080
      :white       => [255, 255, 255, nil], # => #fff
      :yellow      => [255, 255, 0,   nil], # => #ffff00
      :transparent => [0,   0,   0,   0  ]} # => transparent
    
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
          elsif v =~ RGB_INTEGER
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
      if self.type == :inherit
        self.type.to_s
      else
        self.send(:"to_#{self.type.to_s}")
      end
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
        
        if value =~ VALID_HEX_COLOR
          return [:hex].concat(self.class.convert_hex(value))
        end
        
        if value =~ VALID_RGB_COLOR
          return [:rgb].concat(self.class.convert_rgb(value))
        end
        
        if value =~ VALID_RGBA_COLOR
          return [:rgba].concat(self.class.convert_rgba(value))
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
          if value =~ RGB_INTEGER
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
        rgbacolor.sub(/^\s*rgba\(\s*/, "").
        sub(/\s*\)\s*$/, "").
        split(/\s*,\s*/).
        map do |value|
          if value =~ RGB_INTEGER
            value.to_i
          elsif value =~ PERCENTAGE
            (value.chop.to_f * 255 / 100).round
          else
            value.to_f
          end
        end
      end
    end
  end
  
end
