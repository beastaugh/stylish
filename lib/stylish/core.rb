module Stylish
  
  class Stylesheet
    include Formattable
    
    attr_accessor :rules
    
    def initialize(selectors = nil, declarations = nil, options = {}, &block)
      accept_format(/\s*/m, "\n")
      
      options = {:images => ''}.merge(options)
      
      @images_path = Pathname.new(options[:images])
      
      @rules = []
      Description.new(self, selectors, declarations).instance_eval(&block) if block
    end
    
    def rule(selectors = nil, declarations = nil)
      @rules << Rule.new(selectors, declarations)
    end
    
    def image(path)
      "url('#{(@images_path + path).to_s}')"
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
    end
  end
  
  class Rule
    include Formattable
    
    attr_accessor :selectors, :declarations
    
    def initialize(selectors, declarations)
      accept_format(/^\s*%s\s*\{\s*%s\s*\}\s*$/m, "%s {%s}")
      
      if selectors.is_a? String
        @selectors = selectors.strip.split(/\s*,\s*/).
          inject(Selectors.new) {|m, s| m << Selector.new(s) }
      else
        @selectors = selectors
      end
      
      if declarations.is_a? String
        @declarations = declarations.strip.scan(/([a-z\-]+):(.+?);/).map do |p, v|
          Declaration.new(p, v)
        end
      elsif declarations.is_a? Hash
        @declarations = declarations.to_a.map do |d|
          Declaration.new(d[0], d[1])
        end
      else
        @declarations = declarations
      end
    end
    
    def to_s
      sprintf(@format, @selectors.join, @declarations ? @declarations.join(" ") : "")
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
      @value = val
      self.property = prop
    end
    
    def property
      @property
    end
    
    def property=(prop)
      @property = SHORTHANDS.has_key?(prop) ? SHORTHANDS[prop] : prop.to_s
    end
    
    def to_s
      sprintf(@format, @property, @value)
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
        @value = self.send(('parse_' + type.to_s).to_sym, val)
        @type = type and return unless @value.nil?
      end
      
      raise ArgumentError, "#{val} is not a valid keyword, hex or RGB color value."
    end
    
    private
    
    def parse_inherit(val)
      val if val == "inherit"
    end
    
    def parse_keyword(code)
      KEYWORDS[code]
    end
    
    def parse_hex(val)
      val.sub(/^#/, "").downcase if val =~ VALID_HEX_COLOR
    end
    
    def parse_rgb(val)
      if val.is_a? String
        val = val.scan(/-?\d{1,3}%?/)
        return if val.nil?
      end
      
      def percentage?(item)
        item.to_s =~ /^\d{1,3}%$/ && item.chop.to_i <= 100
      end
      
      def less_than_256?(item)
        item.to_s =~ /^-?\d{1,3}$/ && item.to_i < 256
      end
      
      rgb = val[0..2].inject([]) do |memo, v|
        if less_than_256?(v)
          v = v.to_i
        elsif !percentage?(v)
          return
        end
        
        memo << v
      end
      
      return rgb.to_a.length == 3 ? rgb : nil
    end
  end
  
  class Background
    PROPERTIES = {
      :color => "background-color",
      :image => "background-image",
      :repeat => "background-repeat",
      :position => "background-position",
      :attachment => "background-attachment",
      :transparent => nil,
      :compressed => nil
    }
    
    REPEAT_VALUES = ["repeat", "repeat-x", "repeat-y", "no-repeat"]
    ATTACHMENT_VALUES = ["scroll", "fixed", "inherit"]
    HORIZONTAL_POSITIONS = ["left", "center", "right"]
    VERTICAL_POSITIONS = ["top", "center", "bottom"]
    
    def initialize(options)
      PROPERTIES.each_key do |name|
        self.class.send(:attr_reader, name)
        unless options[name].nil?
          self.send((name.to_s + '=').to_sym, options[name])
        end
      end
    end
    
    # Input validation for colours is handled by the Color class, which will
    # raise an ArgumentError if the argument is an invalid colour value.
    def color=(val)
      @color = Color.new(val)
    end
    
    def transparent=(val)
      @transparent = val if val === true || val == false
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
      @compressed = (val == true) ? true : false
    end
  end
  
end
