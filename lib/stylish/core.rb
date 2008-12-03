module Stylish
  
  class Stylesheet
    attr_accessor :rules
    
    FORMAT = "\n"
    
    def initialize(&block)
      @rules = []
      self.instance_eval(&block)
    end
    
    def rule(selectors = nil, declarations = nil)
      @rules << Rule.new(selectors, declarations)
    end
    
    def to_s
      @rules.map {|r| r.to_s }.join(FORMAT)
    end
  end
  
  class Rule
    attr_accessor :selectors, :declarations
    
    FORMAT = "%s {%s}"
    
    def initialize(selectors, declarations)
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
        @declarations = []
        declarations.each do |p, v|
          @declarations << Declaration.new(p, v)
        end
      else
        @declarations = declarations
      end
    end
    
    def to_s
      sprintf(FORMAT, @selectors.join, @declarations.join(" "))
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
    FORMAT = ", "
    
    def join
      super(FORMAT)
    end
    
    def to_s
      self.join
    end
  end
  
  class Declaration
    attr_accessor :value
    
    FORMAT = "%s:%s;"
    SHORTHANDS = {
      :bgcolor => "background-color",
      :bdcolor => "border-color"
    }
    
    def initialize(prop, val = nil)
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
      sprintf(FORMAT, @property, @value)
    end
  end
  
end
