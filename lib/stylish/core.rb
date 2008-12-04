module Stylish
  
  class Stylesheet
    include Formattable
    
    attr_accessor :rules
    
    def initialize(selectors = nil, declarations = nil, &block)
      accept_format(/\s*/m, "\n")
      
      @rules = []
      Description.new(self, selectors, declarations).instance_eval(&block) if block
    end
    
    def rule(selectors = nil, declarations = nil)
      @rules << Rule.new(selectors, declarations)
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
  
end
