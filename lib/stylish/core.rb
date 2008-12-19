module Stylish
  
  class Stylesheet
    include Formattable
    
    attr_reader :rules
    
    def initialize(selectors = nil, declarations = nil, options = {}, &block)
      accept_format(/\s*/m, "\n")
      options = {:images => ''}.merge(options)
      
      @images_path = Pathname.new(options[:images])
      @rules = []
      
      Description.new(self, selectors, declarations).instance_eval(&block) if block
    end
    
    def rules=(input)
      @rules = input.reject {|obj| !obj.is_a? Rule }.compact
    end
    
    def rule(selectors = nil, declarations = nil)
      @rules << Rule.new(selectors, declarations)
    end
    
    def image(path)
      "url('#{(@images_path + path).to_s}')" if path
    end
    
    def to_s
      @rules.map {|r| r.to_s }.join(@format)
    end
    
    class Description
      def initialize(sheet = nil, selectors = nil, declarations = nil)
        @sheet = sheet || Stylesheet.new
        @selectors = selectors
      end
      
      def rule(selectors = nil, declarations = nil, &block)
        return unless selectors || declarations
        selectors.strip.split(/\s*,\s*/).each do |s|
          selector = @selectors ? "#{@selectors} #{s}" : s
          @sheet.rule(selector, declarations)
          self.class.new(@sheet, selector, declarations).instance_eval(&block) if block
        end
      end
      
      def image(path)
        @sheet.image(path)
      end
      
      def background(options)
        options.merge! :image => @sheet.image(options[:image])
        Background.new(options)
      end
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
          m << Declaration.new(d[0], d[1])
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
          if @header
            @lines << arg
          else
            @header = arg
          end
        elsif arg.is_a? Hash
          @metadata.merge!(arg)
        end
      end
      
      def to_s
        sprintf("/**\n%s\n */", [
          sprintf(" * %s", @header),
          @lines.map {|l| ' * ' + l }.join("\n"),
          @metadata.to_a.map {|name, value|
            sprintf(" * @%s %s", name.to_s, value.to_s)
          }.join("\n")
        ].join("\n *\n"))
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
    
    TYPES = [:inherit, :keyword, :hex, :rgb]
    
    VALID_HEX_COLOR = /^#?([\da-fA-F]{3}){1,2}$/
    
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
      if @type == :inherit
        @value
      elsif @type == :rgb
        "rgb(#{@value * ", "})"
      else
        "#" + @value
      end
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
      val if val == "inherit"
    end
    
    def self.parse_keyword(code)
      code = code.to_s.downcase
      KEYWORDS[code.to_sym] unless code.empty?
    end
    
    def self.parse_hex(val)
      val.sub(/^#/, "").downcase if val =~ VALID_HEX_COLOR
    end
    
    def self.parse_rgb(val)
      if val.is_a? String
        val = val.scan(/-?\d{1,3}%?/)
        return if val.nil?
      end
      
      rgb = val.to_a[0..2].inject([]) do |memo, v|
        if less_than_256?(v)
          v = v.to_i
        elsif !percentage?(v)
          return
        end
        
        memo << v
      end
      
      return rgb.to_a.length == 3 ? rgb : nil
    end
    
    def self.percentage?(item)
      item.to_s =~ /^\d{1,3}%$/ && item.chop.to_i <= 100
    end
    
    def self.less_than_256?(item)
      item.to_s =~ /^-?\d{1,3}$/ && item.to_i < 256
    end
  end
  
  class Background
    attr_reader :image,
                :repeat,
                :position,
                :attachment,
                :transparent,
                :compressed
    
    PROPERTIES = [
      [:color, "background-color"],
      [:image, "background-image"],
      [:repeat, "background-repeat"],
      [:position, "background-position"],
      [:attachment, "background-attachment"],
      [:transparent],
      [:compressed]]
    
    REPEAT_VALUES = ["repeat", "repeat-x", "repeat-y", "no-repeat"]
    ATTACHMENT_VALUES = ["scroll", "fixed", "inherit"]
    HORIZONTAL_POSITIONS = ["left", "center", "right"]
    VERTICAL_POSITIONS = ["top", "center", "bottom"]
    
    def initialize(options)
      PROPERTIES.each do |name, property|
        if options[name]
          self.send(:"#{name.to_s}=", options[name])
        end
      end
    end
    
    def color
      return "transparent" if @transparent
      @color
    end
    
    # Input validation for colours is handled by the Color class, which will
    # raise an ArgumentError if the argument is an invalid colour value.
    def color=(val)
      @color = Color.new(val)
    end
    
    def transparent=(val)
      @transparent = val == true || nil
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
    
    def join(str = "")
      to_s
    end
    
    def to_s
      decs = PROPERTIES.reject {|n, p| p.nil? }.map {|n, p|
        value = self.send(n)
        [p.to_s, value] unless value.nil?
      }.compact
      
      if @compressed
        "background:#{decs.map {|p, v| v }.compact.join(" ")};"
      else
        decs.map {|p, v| "#{p}:#{v.to_s};" }.join(" ")
      end
    end
  end
  
end
