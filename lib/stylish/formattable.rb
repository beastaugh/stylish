module Stylish
  
  module Formattable
    
    def format
      @format
    end
    
    def format=(format)
      if format_validates?(format)
        @format = format
      else
        raise ArgumentError, "Not an allowed format."
      end
    end
    
    private
    
    def accept_format(pattern, default)
      @format_pattern = pattern if pattern.is_a? Regexp
      self.format = default
    end
    
    def format_validates?(format)
      format =~ @format_pattern
    end
  end
  
end
