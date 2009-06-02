module Stylish
  
  # The Formattable mixin gives an API for changing the output format of any of
  # Stylish's core classes, as long as the new output format matches the regex
  # provided when the class was declared. This is because in order to generate
  # valid CSS, strings must be joined in the correct way.
  #
  # For example, a rule's selectors must be comma-separated and its
  # declarations must be wrapped in curly braces, while each declaration
  # consists of a property name and a value separated by a colon and
  # terminating with a semicolon.
  #
  # In order to employ the Formattable mixin, it must be included into a class
  # and the accept_format method must be called with the allowed format (as a
  # regular expression) and the default format (a string).
  #
  #   class Stylesheet
  #     include Formattable
  #     accept_format(/\s*/m, "\n")
  #   end
  #
  module Formattable
    
    def self.included(base)
      base.extend(FormattableMethods)
    end
    
    module FormattableMethods
      attr_reader :format, :default_format
      
      def format=(format)
        if format_validates?(format)
          @format = format
        else
          raise ArgumentError, "Not an allowed format."
        end
      end
      
      # Reset the class's format string to its default value.
      def reset_format!
        self.format = @default_format
      end
      
      private
      
      def accept_format(pattern, default)
        @format_pattern = pattern if pattern.is_a? Regexp
        self.format     = default
        @default_format = default
      end
      
      def format_validates?(format_string)
        format_string =~ @format_pattern
      end
      
      def inherited(subclass)
        ["format", "format_pattern"].each do |attribute|
          instance_var = "@#{attribute}"
          subclass.instance_variable_set(instance_var,
            instance_variable_get(instance_var))
        end
      end
    end
  end
  
end
