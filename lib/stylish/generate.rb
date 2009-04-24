module Stylish
  
  # The generate method is the starting point for the stylesheet generation
  # DSL. The method should be passed a block, and the various DSL methods then
  # called within that context, e.g. as follows:
  #
  #     style = Stylish.generate do
  #       body :margin => "1em"
  #       rule ".error" do
  #         p :color => "#f00"
  #         em :font_weight => "bold"
  #       end
  #     end
  #
  # When serialised, the generated stylesheet would look like this:
  #
  #     body {margin:1em;}
  #     .error p {color:#f00;}
  #     .error em {font-weight:bold;}
  #
  # Further examples can be found in the example/ directory and in the
  # +GenerateTest+ class.
  #
  # * example/tarski.rb
  # * test/generate_test.rb
  #
  # The options argument is currently unused.
  def self.generate(options = {}, &block)
    dsl = Generate::Description.new
    dsl.instance_eval(&block)
    dsl.node
  end
  
  # The +Generate+ module is a general namespace for the stylesheet generation
  # DSL components. It contains various modules and classes which together are
  # used to generate the intermediate data-structures of selector trees, and
  # ultimately CSS code.
  module Generate
    
    # The +parse_declarations+ method deals with three things: turning the
    # hashes passed to the +Description#rule+ method into +Declarations+
    # objects; renaming property names to use dashes rather than underscores
    # (since the former are correct CSS but are invalid Ruby, at least when
    # quotation marks are not used to delimit the symbol); and handling special
    # cases.
    #
    # There are currently two main special cases: colours and backgrounds. Each
    # of these property types have their own +Stylish+ classes, and thus to
    # create a rich datastructure which takes advantage of these powerful
    # classes the declarations passed to the stylesheet generation DSL need to
    # be parsed with this in mind.
    def self.parse_declarations(declarations)
      declarations.to_a.inject(Declarations.new) do |ds, declaration|
        key, value = declaration
        key        = key.to_s.sub("_", "-").to_sym
        
        if value.is_a? Symbol
          value = Variable.new(value)
        end
        
        if key == :background
          declaration = Background.new(value)
        elsif key == :color
          declaration = Declaration.new("color", Color.new(value))
        else
          declaration = Declaration.new(key, value)
        end
        
        ds << declaration
      end
    end
    
    class Variable
      
      def initialize(name)
        @name = name
      end
      
      def to_s(symbols)
        symbols[@name]
      end
    end
    
    # Often the selector associated with a call to the rule method would simply
    # be a single HTML element name. This has been factored out by adding
    # methods to the Description DSL class corresponding to all the HTML
    # elements. Consider the following (contrived) example.
    #
    #     Stylish.generate do
    #       body do
    #         div do
    #           a :font_weight => bold
    #         end
    #       end
    #     end
    #
    # Which would then serialise to the following:
    #
    #     body div a {font-weight:bold;}
    #
    module ElementMethods
      HTML_ELEMENTS.each do |element|
        next if self.respond_to?(element)
        
        module_eval <<-DEF
          def #{element.to_s}(declarations = nil, &block)
            self.rule("#{element.to_s}", declarations, &block)
          end
        DEF
      end
    end
    
    # Description objects are the core of the stylesheet generation DSL. Blocks
    # passed into the +Stylish#generate_ method are executed in the context of
    # a +Description+ object. All the DSL methods, +rule+, +comment+, and all
    # the HTML element methods are all methods on instances of the
    # +Description+ class.
    class Description
      include ElementMethods
      
      attr_reader :node
      
      # +Description+ instances are associated with a particular node in a
      # selector tree; if no node is assigned to them on creation, they
      # associate with a new root, i.e. a +Stylesheet+ object.
      def initialize(context = nil)
        @node = context || Stylesheet.new
      end
      
      # The +rule+ method is the most general and powerful part of the DSL. It
      # can be used to add a single +Rule+, with attendant declarations, or to
      # create a selector namespace within which further rules or namespaces
      # can be added.
      #
      # The nested structure created is precisely that of a selector tree; the
      # rule method adds +Rule+ leaves and +SelectorScope+ nodes to the tree,
      # whose root is a +Stylesheet+ object.
      #
      # Either a set of declarations or a block must be passed to the method;
      # failing to do so will result in an early return which creates no
      # additional objects. The following example demonstrates the various ways
      # in which the method can be used:
      #
      #     Stylish.generate do
      #       rule ".section", :margin_bottom => "10px"
      #
      #       rule "form" do
      #         rule ".notice", :color => "#00f"
      #         rule "input[type=submit]", :font_weight => "normal"
      #       end
      #
      #       rule "body", :padding => "0.5em" do
      #         rule "div", :margin => "2px"
      #       end
      #     end
      #
      # This would produce a stylesheet with the following rules:
      #
      #     .section {margin-bottom:10px;}
      #
      #     form .notice {color:#00f;}
      #     form input[type=submit] {font-weight:normal;}
      #
      #     body {padding:0.5em;}
      #     body div {margin:2px;}
      #
      # Usefully, a call to #rule which passes in both declarations and a block
      # will produce a single +Rule+ with the declarations attached, then
      # create a new +SelectorScope+ node with the same selectors and execute
      # the block in that context.
      #
      # If several selectors and a block are passed to +rule+, new
      # +SelectorScope+ nodes will be created for each selector and the block
      # will be executed in all the contexts created, not just one.
      def rule(selectors, declarations = nil, &block)
        return unless declarations || block
        
        selectors = [selectors] unless selectors.is_a?(Array)
        selectors.map! do |s|
          Selector.new(s.is_a?(Symbol) ? Variable.new(s) : s)
        end
        
        declarations = Generate.parse_declarations(declarations)
        
        unless block
          @node << Rule.new(selectors, declarations)
        else
          selectors.each do |selector|
            unless declarations.empty?
              @node << Rule.new([selector], declarations)
            end
            
            new_node = Tree::SelectorScope.new(selector)
            @node << new_node
            
            self.class.new(new_node).instance_eval(&block)
          end
        end
      end
      
      # Adds a +Comment+ object to the current node. This method simply hands
      # its arguments off to the +Comment+ initialiser, and hence implements
      # its API precisely.
      def comment(*args)
        @node << Comment.new(*args)
      end
    end
    
  end
end
