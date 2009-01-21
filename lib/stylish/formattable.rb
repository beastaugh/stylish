module Stylish
  
  # The Formattable mixin gives an API for changing the output format of any of
  # Stylish's core objects, as long as the new output format matches the regex
  # provided in the object's initialize method. This is because in order to
  # serialise a valid CSS document, strings must be joined in the correct way.
  #
  # For example, a rule's selectors must be comma-separated and its
  # declarations must be wrapped in curly braces, while each declaration
  # consists of a property name and a value separated by a colon and
  # terminating with a semicolon.
  #
  # In order to employ the Formattable mixin, it must be included into a class
  # and the #accept_format method must be called in the class's #initialize
  # method, setting the allowed format and the default format.
  #
  #   class Stylesheet
  #     include Formattable
  #
  #     def initialize
  #       accept_format(/\s*/m, "\n")
  #     end
  #   end
  #
  # If one then creates a new Stylesheet object, one can modify the way it's
  # formatted when serialised to CSS code.
  #
  #   stylesheet = Stylesheet.new
  #   stylesheet.format # => "\n"
  #   stylesheet.format = "\n\n"
  #   stylesheet.format # => "\n\n"
  #
  module Formattable
    attr_reader :format
    
    # Attribute writer that sets the object's format attribute. The argument
    # must match the regular expression passed to #accept_format in the
    # object's initialize method.
    def format=(format)
      if format_validates?(format)
        @format = format
      else
        raise ArgumentError, "Not an allowed format."
      end
    end
    
    private
    
    # Because this is a private method, it . Ruby's object system and
    # metaprogramming facilities means that these restrictions are evaded
    # without much difficulty; making this method private indicates intent
    # rather than providing a serious barrier to inadvisable behaviour.
    #
    # Within Stylish, #accept_format is used only in the initialize method of
    # the various core classes which may be serialised to CSS code.
    def accept_format(pattern, default)
      @format_pattern = pattern if pattern.is_a? Regexp
      self.format = default
    end
    
    # Checks whether a particular string matches the pattern acceptable formats
    def format_validates?(format)
      format =~ @format_pattern
    end
  end
  
end
