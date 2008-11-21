module Stylish
  
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
      Array.instance_method(:join).bind(self).call(FORMAT)
    end
  end
  
  class Declaration
    attr_accessor :property, :value
    
    FORMAT = "%s:%s;"
    
    def initialize(property, value)
      @property, @value = property, value
    end
    
    def to_s
      sprintf(FORMAT, @property, @value)
    end
  end
  
end
