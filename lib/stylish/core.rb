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
          selector = (@selectors) ? "#{@selectors} #{s}" : s
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
      sprintf(@format, @selectors.join, (@declarations) ? @declarations.join(" ") : "")
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
      @property = (SHORTHANDS.has_key?(prop)) ? SHORTHANDS[prop] : prop.to_s
    end
    
    def to_s
      sprintf(@format, @property, @value)
    end
  end
  
  class Color
    TYPES = [:keyword, :hex, :rgb]
    
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
      "#" + @value
    end
    
    def value
      @value
    end
    
    def value=(val)
      TYPES.each do |type|
        @value = self.send(('parse_' + type.to_s).to_sym, val)
        return unless @value.nil?
      end
      
      raise ArgumentError, "Value is not a valid keyword or color hex value."
    end
    
    private
    
    def parse_keyword(code)
      KEYWORDS[code]
    end
    
    def parse_hex(val)
      val.sub(/^#/, "").downcase if val =~ VALID_HEX_COLOR
    end
    
    def parse_rgb(val)
      nil
    end
  end
  
end
