module Stylish
  
  # A list of all valid HTML5 elements. Used primarily in the stylesheet
  # generation DSL as method names.
  HTML_ELEMENTS = [:html, :head, :title, :base, :link, :meta, :style, :script,
                   :noscript, :eventsource, :body, :section, :nav, :article,
                   :aside, :header, :footer, :address, :p, :hr, :br, :pre,
                   :dialog, :blockquote, :ol, :ul, :li, :dl, :dt, :dd, :a, :q,
                   :cite, :em, :strong, :small, :mark, :dfn, :abbr, :time,
                   :progress, :meter, :code, :var, :samp, :kbd, :sub, :sup,
                   :span, :i, :b, :bdo, :ruby, :rt, :rp, :ins, :del, :figure,
                   :img, :iframe, :embed, :object, :param, :video, :audio,
                   :source, :canvas, :map, :area, :table, :caption, :colgroup,
                   :col, :tbody, :thead, :tfoot, :tr, :td, :th, :form,
                   :fieldset, :label, :input, :button, :select, :datalist,
                   :optgroup, :option, :textarea, :output, :details, :datagrid,
                   :command, :bb, :menu, :legend, :div, :h1, :h2, :h3, :h4,
                   :h5, :h6]
  
  # Rule objects represent CSS rules, and serialise to them. They possess one
  # or more selectors, and zero or more declarations. In addition to their
  # importance as the major building-blocks of stylesheets, they act as the
  # leaves of Stylish's stylesheet trees.
  #
  # Their serialisation is controllable to some extent by altering their
  # format attribute; this should never make them lose information when they
  # are serialised.
  #
  # E.g., by changing its format to "%s {\n  %s\n}" a rule that would
  # normally be serialised thus:
  #
  #     body {font-size:81%;}
  #
  # Would instead be serialised like this:
  #
  #     body {
  #       font-size:81%;
  #     }
  #
  class Rule
    include Formattable, Tree::Leaf
    
    attr_reader :selectors, :declarations
    accept_format(/^\s*%s\s*\{\s*%s\s*\}\s*$/m, "%s {%s}")
    
    # Every Rule must have at least one selector, but may have any number of
    # declarations. Empty rules are often used in stylesheets to indicate
    # particular combinations of selectors which may be used to produce
    # particular effects.
    #
    # In Stylish, of course, a Rule's declarations may be amended after its
    # creation:
    #
    #     rule = Stylish::Rule.new([Stylish::Selector.new("body")])
    #     rule.declarations << Stylish::Declaration.new("font-weight", "bold")
    #     rule.to_s # => "body {font-weight:bold;}"
    #
    # This makes Rule objects a very flexible foundation for the higher-level
    # data structures and APIs in Stylish.
    def initialize(selectors, declarations)
      @selectors = selectors.inject(Selectors.new) do |ss, s|
        ss << s
      end
      
      @declarations = declarations.inject(Declarations.new) do |ds, d|
        ds << d
      end
    end
    
    # Serialise the rule to valid CSS code.
    def to_s(symbols = {}, scope = "")
      sprintf(self.class.format, selectors.join(symbols, scope),
        @declarations.to_s(symbols))
    end
  end
  
  # Comment objects form the other concrete leaves of selector trees, and allow
  # stylesheets to be annotated at any point (outside Rules). Their
  # serialisation format follows the well-known JavaDoc and PHPDoc style, with
  # a header, several lines of notes, and key-value information.
  #
  # This format is not amendable; those desirous of their own formatting would
  # be better served by creating their own Comment class, such as the following
  # more basic one:
  #
  #     module Stylish
  #       module Extensions
  #         
  #         class Comment
  #           include Tree::Leaf
  #           
  #           attr_accessor :content
  #           
  #           def initialize(content)
  #             @content = content
  #           end
  #           
  #           def to_s(scope = "")
  #             "/* " + content.to_s + " */"
  #           end
  #         end
  #         
  #       end
  #     end
  #
  class Comment
    include Tree::Leaf
    
    attr_reader :header, :lines, :metadata
    
    # Each Comment can have a header, additional lines of text content (each
    # provided as its own argument), and key-value metadata passed in as a Ruby
    # Hash object.
    #
    #     comment = Comment.new("My wonderful comment",
    #                 "It has several lines of insightful notes,",
    #                 "filled with wisdom and the knowledge of ages.",
    #                 {:author => "Some Egotist"})
    #
    #     comment.to_s # => /**
    #                  #     * My wonderful comment
    #                  #     *
    #                  #     * It has several lines of insightful notes,
    #                  #     * filled with wisdom and the knowledge of ages.
    #                  #     *
    #                  #     * @author Some Egotist
    #                  #     */
    #
    def initialize(*args)
      @lines, @metadata = [], {}
      
      args.each do |arg|
        if arg.is_a? String
          unless @header.nil?
            @lines << arg
          else
            @header = arg
          end
        elsif arg.is_a? Hash
          @metadata.merge! arg
        end
      end
    end
    
    # As Comment objects are the leaves of selector trees, they must implement
    # the serialisation API of those trees, and thus the #to_s method has a
    # scope argument, which is in practice discarded when the serialisation of
    # the comment occurs.
    def to_s(symbols = {}, scope = "")
      if @lines.empty? && @metadata.empty?
        sprintf("/**\n * %s\n */", @header)
      else
        header = sprintf(" * %s", @header) unless @header.nil?
        lines = @lines.map {|l| ' * ' + l }.join("\n") unless @lines.empty?
        metadata = @metadata.to_a.map {|name, value|
          sprintf(" * @%s %s", name.to_s, value.to_s)
        }.join("\n") unless @metadata.empty?
        
        sprintf("/**\n%s\n */", [
          header || nil,
          lines || nil,
          metadata || nil
        ].compact.join("\n *\n"))
      end
    end
  end
  
  # Selector objects are just string containers, which when serialised are
  # passed the scope in which they are situated. The Selector class is one of
  # Stylish's most basic units, and are generally used only by internal APIs
  # when constructing Rule objects, rather than by end users (although nothing
  # prevents this; it is merely inconvenient to do so).
  class Selector
    
    # Selectors are immutable once created; the value of a given Selector must
    # be set when the object is created.
    def initialize(selector)
      @selector = selector
    end
    
    # Each Rule possesses one or more Selectors. Rules are often placed in
    # selector trees, and thus when serialised a Selector must be made aware
    # of the context or scope in which it is being serialised.
    #
    #     Selector.new("p").to_s("body") # => "body p"
    #
    # The Selector class is also used internally by the Tree::SelectorScope
    # class, to store its scope value.
    def to_s(symbols = {}, scope = "")
      (scope.empty? ? "" : scope + " ") + @selector
    end
  end
  
  # Selectors objects are simply used to group Selector objects for more
  # convenient storage and serialisation.
  class Selectors < Array
    include Formattable
    
    accept_format(/^\s*,\s*$/m, ", ")
    
    # The join method overrides the superclass' method in order to always use a
    # specific separator, and so that the scope that the selectors are being
    # used in can be passed through when Rules etc. are serialised.
    def join(symbols = {}, scope = "")
      self.inject("") do |ss, s|
        (ss.empty? ? "" : ss + self.class.format) + s.to_s(symbols, scope)
      end
    end
    
    # The to_s method alternative way of calling the join method.
    def to_s(symbols = {}, scope = "")
      self.join(symbols, scope)
    end
  end
  
  # Each Rule may have one or more Declaration objects, and usually has more
  # than one. In a sense, declarations are the business end of stylesheets:
  # they are where the set of elements specified by a rule's selectors are
  # given their various attributes.
  class Declaration
    include Formattable
    
    attr_accessor :value
    accept_format(/^\s*%s\s*:\s*%s;\s*$/m, "%s:%s;")
    
    # Each Declaration has a property name and a value.
    def initialize(name, value)
      self.value = value
      self.name  = name
    end
    
    # The property name of the Declaration.
    def name
      @property_name
    end
    
    # Property names are CSS identifiers.
    def name=(name)
      @property_name = name.to_s
    end
    
    # The value of the Declaration's property.
    def value=(value)
      @value = value
    end
    
    # Serialising a declaration produces a name-value pair separated by a colon
    # and terminating with a semicolon, for instance
    #
    #     declaration = Declaration.new("font-style", "italic")
    #     declaration.to_s # => "font-style:italic;"
    #
    # Since the formatting can be adjusted via the #format= accessor, the exact
    # spacing of the declaration can be controlled if desired.
    def to_s(symbols = {})
      if @value.is_a?(Generate::Variable) || @value.is_a?(Color)
        value = @value.to_s(symbols)
      else
        value = @value.to_s
      end
      
      sprintf(self.class.format, @property_name.to_s, value)
    end
  end
  
  # Declarations subclasses Array so that whenever #join is called, the
  # instance's format attribute will be used as the join string, rather than
  # the empty string.
  class Declarations < Array
    include Formattable
    
    accept_format(/^\s*$/m, " ")
    
    # The format attribute is always used as the separator when joining the
    # elements of a Declarations object.
    def join
      super(self.class.format)
    end
    
    # Returns a string by converting each element to a string, separated by the
    # format attribute. Assuming that its contents are indeed Declaration
    # objects, this will invoke their own #to_s method and generating correct
    # CSS code.
    def to_s(symbols = {})
      self.inject("") do |a, o|
        a << (a.empty? ? "" : self.class.format) << o.to_s(symbols)
      end
    end
  end
  
  # PropertyBundle objects are simple wrappers around property values with
  # multiple values.
  class PropertyBundle < Array
    include Formattable
    
    accept_format(/^\s*,\s*$/m, ", ")
    
    def to_s
      self.join(self.class.format)
    end
  end
  
end
