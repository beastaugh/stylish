module Stylish
  
  class Rule
    attr_accessor :selectors, :declarations
    
    def initialize(selectors, declarations, options = {})
      options = {:format => "%s {%s}"}.merge(options)
      @format = options[:format]
      
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
      sprintf(@format, @selectors.join, @declarations.join(" "))
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
    
    def initialize(options = {})
      default_format = ", "
      options = {:format => default_format}.merge(options)
      
      if options[:format] =~ /^\s*,\s*$/m
        @format = options[:format]
      else
        @format = default_format
      end
      
      super()
    end
    
    def join
      self.class.superclass.instance_method(:join).bind(self).call(@format)
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
