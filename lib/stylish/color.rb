module Stylish
  
  # The Color class is intended to eventually implement the entirety of the
  # {CSS Color Module Level 3}[link:http://www.w3.org/TR/css3-color/].
  class Color
    attr_reader :type
    
    TYPES = [:inherit, :transparent, :keyword, :hex, :rgba]
    
    VALID_HEX_COLOR = /^#?([\da-fA-F]{3}){1,2}$/
    PERCENTAGE = /^-?(0\.)?\d+%$/
    
    KEYWORDS = {
      :aqua => "00ffff",
      :black => "000",
      :blue => "0000ff",
      :fuchsia => "ff00ff",
      :gray => "808080",
      :green => "008000",
      :lime => "00ff00",
      :maroon => "800000",
      :navy => "000080",
      :olive => "808000",
      :orange => "ffA500",
      :purple => "800080",
      :red => "ff0000",
      :silver => "c0c0c0",
      :teal => "008080",
      :white => "fff",
      :yellow => "ffff00"
    }
    
    def initialize(value)
      self.value = value
    end
    
    def to_s
      if @type == :rgba
        "rgb(#{@value * ", "})"
      elsif @type == :hex
        "#" + @value
      else
        @value.to_s
      end
    end
    
    # Inherit and transparent have no hex equivalents, so the method simply
    # returns nil. Hex values are simply returned (with a leading octothorpe)
    # while keywords are converted to their hex equivalent.
    #
    # RGBA values have an opacity value which is not convertible to a six-
    # character hexadecimal string, so this information is stripped and a
    # conventional RGB value is then converted to hex.
    #
    # All values will be converted, if possible, from six-digit to three-digit
    # notation, replacing replicated digits with simple values.
    #
    #     #ffffff => #fff
    #     #ffbb00 => #fb0
    #
    def to_hex
      compress = lambda do |str|
        return str unless str.length % 2 == 0
        
        compressed = str.scan(/[\da-fA-F]{2}/).inject("") do |memo, s|
          memo += s[0,1] == s[1,2] ? s[0,1] : s
        end
        
        compressed.length == str.length / 2 ? compressed : str
      end
      
      return if @type == :inherit || @type == :transparent
      return "#" + compress.call(@value) if @type == :hex
      return "#" + compress.call(KEYWORDS[@value]) if @type == :keyword
      
      "#" + @value[0..2].inject([]) {|memo, v|
        v = v.chop.to_i * 255 / 100 if v =~ PERCENTAGE
        v = v.to_s(16)
        v = "0" + v if v.length < 2
        v = compress.call(v) || v
        memo << v
      }.join
    end
    
    def value
      @value
    end
    
    def value=(val)
      TYPES.each do |type|
        @value = self.class.send(:"parse_#{type.to_s}", val)
        @type = type and return unless @value.nil?
      end
      
      raise ArgumentError, "#{val.inspect} is not a valid keyword, hex or RGB color value."
    end
    
    def self.like?(value)
      TYPES.each do |type|
        return true unless self.send(:"parse_#{type.to_s}", value).nil?
      end
      
      false
    end
    
    private
    
    def self.parse_inherit(val)
      "inherit" if val.to_s == "inherit"
    end
    
    def self.parse_transparent(val)
      "transparent" if val.to_s == "transparent"
    end
    
    def self.parse_keyword(code)
      code = code.to_s.downcase
      return if code.nil? || code.empty?
      code = code.to_sym
      code if KEYWORDS.has_key?(code)
    end
    
    def self.parse_hex(val)
      val.sub(/^#/, "").downcase if val =~ VALID_HEX_COLOR
    end
    
    def self.parse_rgba(val)
      if val.is_a? String
        val = val.sub(/^\s*rgb\(\s*/, "").sub(/\s*\)\s*$/, "").split(/\s*,\s*/)
        return if val.nil?
      end
      
      rgba = Array(val)[0..3].inject([]) {|memo, v|
        if memo.length == 3
          opacity = v.to_f
          v = (0 <= opacity && opacity <= 1) ? opacity : nil
        elsif v.to_s =~ /^[+-]?\d{1,3}$/ && v.to_i < 256
          v = v.to_i
        else
          return unless v.to_s =~ PERCENTAGE
        end
        
        memo << v
      }.compact
      
      return (3..4).include?(rgba.to_a.length) ? rgba : nil
    end
  end
  
end
