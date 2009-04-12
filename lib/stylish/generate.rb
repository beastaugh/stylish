module Stylish
  
  def self.generate(options = {}, &block)
    dsl = Generate::Description.new
    dsl.instance_eval(&block)
    dsl.node
  end
  
  module Generate
    
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
        
        declarations = declarations.to_a.map do |p, v|
          Declaration.new(p.to_s.sub("_", "-"), v)
        end
        
        unless block
          @node << Rule.new(selectors, declarations)
        else
          selectors.each do |selector|
            unless declarations.empty?
              @node << Rule.new(selector, declarations)
            end
            
            new_node = Tree::SelectorScope.new(selector.to_s)
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
