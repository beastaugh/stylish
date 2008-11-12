module Stylish
  
  class Rule
    attr_accessor :selectors, :declarations
    
    def initialize(selectors, declarations, options = {})
      options = {:format => "%s {%s}"}.merge(options)
      @format = options[:format]
      
      if selectors.is_a? String
        @selectors = selectors.strip.split(/\s*,\s*/).map {|s| Selector.new(s) }
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
      sprintf(@format, @selectors.join(", "), @declarations.join(" "))
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
  
  class Declaration
    attr_accessor :property, :value
    
    def initialize(property, value, options = {})
      options = {:format => "%s:%s;"}.merge(options)
      @format = options[:format]
      
      @property = property
      @value = value
    end
    
    def to_s
      sprintf(@format, @property, @value)
    end
  end
  
end
