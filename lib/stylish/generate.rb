module Stylish
  
  def self.generate(options = {}, &block)
    dsl = Generate::Description.new
    dsl.instance_eval(&block)
    dsl.node
  end
  
  module Generate
    
    module DeclarationsParser
      
      def self.parse(declarations)
        declarations.to_a.inject(Declarations.new) do |ds, declaration|
          key, value = declaration
          key        = key.to_s.sub("_", "-").to_sym
          
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
    end
    
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
    
    class Description
      include ElementMethods
      
      attr_accessor :node
      
      def initialize(context = nil)
        @node = context || Stylesheet.new
      end
      
      def rule(selectors, declarations = nil, &block)
        return unless declarations || block
        
        selectors = [selectors] unless selectors.is_a?(Array)
        selectors.map! {|s| Selector.new(s) }
        
        declarations = DeclarationsParser.parse(declarations)
        
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
      
      def comment(*args)
        @node << Comment.new(*args)
      end
    end
    
  end
end
