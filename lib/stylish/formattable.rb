module Stylish
  
  module Formattable
    attr_reader :format
    
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
