module Stylish
  
  class Stylesheet
    include Formattable
    
    attr_reader :content
    
    def initialize(selectors = nil, declarations = nil, options = {}, &block)
      accept_format(/\s*/m, "\n")
      options = {:images => ''}.merge(options)
      
      @images_path = Pathname.new(options[:images])
      @content = []
      
      Description.new(self, selectors, declarations).instance_eval(&block) if block
    end
    
    def rules
      @content.select {|obj| obj.is_a? Rule }
    end
    
    def comments
      @content.select {|obj| obj.is_a? Comment }
    end
    
    def rules=(input)
      @content = input.select {|obj| obj.is_a?(Rule) || obj.is_a?(Comment) }
    end
    
    def to_s
      @content.map {|r| r.to_s }.join(@format)
    end
  end
    
  class Rule
    include Formattable
    
    attr_reader :selectors, :declarations
    
    def initialize(selectors, declarations)
      accept_format(/^\s*%s\s*\{\s*%s\s*\}\s*$/m, "%s {%s}")
      
      self.selectors = selectors
      self.declarations = declarations
    end
    
    def selectors=(input)
      if input.is_a? String
        @selectors = self.class.parse_selectors_string(input)
      elsif input.is_a? Array
        @selectors = input.inject(Selectors.new) do |m, s|
          if s.is_a? Selector
            m << s
          elsif s.is_a? String
            m << Selector.new(s)
          end
        end
      else
        @selectors = Selectors.new
      end
    end
    
    def declarations=(input)
      @declarations = input and return if input.is_a? Declarations
      @declarations = Declarations.new << input and return if input.is_a? Background
      
      if input.is_a? String
        declarations = self.class.parse_declarations_string(input)
      elsif input.is_a?(Hash) || input.is_a?(Array)
        declarations = input.to_a
      end
      
      unless declarations.nil?
        @declarations = declarations.inject(Declarations.new) do |m, d|
          if d.is_a? Background
            m << d
          else
            m << Declaration.new(d[0], d[1])
          end
        end
      end
    end
    
    def to_s
      sprintf(@format, @selectors.join, @declarations ? @declarations.join : "")
    end
    
    private
    
    def self.parse_selectors_string(input)
      input.strip.split(/\s*,\s*/).
        inject(Selectors.new) {|m, s| m << Selector.new(s) }
    end
    
    def self.parse_declarations_string(input)
      input.strip.scan(/([a-z\-]+):(.+?);/)
    end
  end
  
  class Comment
    attr_reader :header, :lines, :metadata
    
    def initialize(*args)
      @lines, @metadata = [], {}
      
      args.each do |arg|
        if arg.is_a? String
          unless @header.nil?
            @lines << arg
          else
            @header = arg
          end
        elsif arg.is_a? Hash
          @metadata.merge!(arg)
        end
      end
      
      def to_s
        if @lines.empty? && @metadata.empty?
          sprintf("/**\n * %s\n */", @header)
        else
          header = sprintf(" * %s", @header) unless @header.nil?
          lines = @lines.map {|l| ' * ' + l }.join("\n") unless @lines.empty?
          metadata = @metadata.to_a.map {|name, value|
            sprintf(" * @%s %s", name.to_s, value.to_s)
          }.join("\n") unless @metadata.empty?
          
          sprintf("/**\n%s\n */", [
            header || nil,
            lines || nil,
            metadata || nil
          ].compact.join("\n *\n"))
        end
      end
    end
  end
  
  class Selector
    
    def initialize(str)
      @selector = str.to_s
    end
    
    def to_s
      @selector
    end
  end
  
  class Selectors < Array
    include Formattable
    
    def initialize(*args)
      accept_format(/^\s*,\s*$/m, ", ")
      super
    end
    
    def join
      super(@format)
    end
    
    def to_s
      self.join
    end
  end
  
  class Declaration
    include Formattable
    
    attr_accessor :value
    
    SHORTHANDS = {
      :bgcolor => "background-color",
      :bdcolor => "border-color"
    }
    
    def initialize(prop, val = nil)
      accept_format(/^\s*%s\s*:\s*%s;\s*$/m, "%s:%s;")
      self.value = val
      self.property = prop
    end
    
    def property
      @property
    end
    
    def property=(prop)
      @property = SHORTHANDS.has_key?(prop) ? SHORTHANDS[prop] : prop.to_s
    end
    
    def value=(val)
      @value = Color.new(val) and return if Color.like?(val)
      @value = val
    end
    
    def to_s
      sprintf(@format, @property, @value)
    end
  end
  
  class Declarations < Array
    include Formattable
    
    def initialize(*args)
      accept_format(/^\s*$/m, " ")
      super
    end
    
    def join
      super(@format)
    end
    
    def to_s
      self.join
    end
  end
  
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
      
      rgba = val.to_a[0..3].inject([]) {|memo, v|
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
  
  class Background < Declaration
    attr_reader :color,
                :image,
                :repeat,
                :position,
                :attachment,
                :compressed
    
    PROPERTIES = [
      [:color, "background-color"],
      [:image, "background-image"],
      [:repeat, "background-repeat"],
      [:position, "background-position"],
      [:attachment, "background-attachment"],
      [:compressed]]
    
    REPEAT_VALUES = ["repeat", "repeat-x", "repeat-y", "no-repeat"]
    ATTACHMENT_VALUES = ["scroll", "fixed", "inherit"]
    HORIZONTAL_POSITIONS = ["left", "center", "right"]
    VERTICAL_POSITIONS = ["top", "center", "bottom"]
    
    def initialize(options)
      accept_format(/^\s*%s\s*:\s*%s;\s*$/m, "%s:%s;")
      self.value = options
    end
    
    # Input validation for colours is handled by the Color class, which will
    # raise an ArgumentError if the argument is an invalid colour value.
    def color=(val)
      @color = Color.new(val)
    end
    
    def image=(path)
      @image = path if path.is_a?(String) || path.is_a?(File)
    end
    
    def repeat=(val)
      @repeat = val if REPEAT_VALUES.include?(val)
    end
    
    # Only position keywords are currently handled, not percentages or lengths.
    def position=(val)
      xpos, ypos = val.split(/\s+/) << "center"
      if HORIZONTAL_POSITIONS.include?(xpos) && VERTICAL_POSITIONS.include?(ypos)
        @position = [xpos, ypos]
      end
    end
    
    def attachment=(val)
      @attachment = val if ATTACHMENT_VALUES.include?(val)
    end
    
    # Set this to true to generate a compressed declaration, e.g.
    #
    #     background:#ccc url('bg.png') no-repeat 0 0;
    #
    # As opposed to the uncompressed version:
    #
    #     background-color:#ccc; background-image:url('bg.png');
    #     background-repeat:no-repeat; background-position:0 0;
    #
    def compressed=(val)
      @compressed = val == true || nil
    end
    
    # Override Declaration#property, since it's not compatible with the
    # internals of this class.
    def property
      PROPERTIES.reject {|n, p| p.nil? }.map {|n, p|
        value = self.send(n)
        p.to_s unless value.nil?
      }.compact
    end
    
    # Override Declaration#property=, since it's not compatible with the
    # internals of this class.
    def property=(val)
      raise NoMethodError, "property= is not defined for Background."
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
    
    def to_s
      if @compressed
        "background:#{self.value(true).map {|p, v| v }.compact.join(" ")};"
      else
        self.value(true).map {|p, v| sprintf(@format, p, v.to_s) }.join(" ")
      end
    end
  end
  
end
