module Stylish
  module Tree
    
    # Stylish trees are formed from nodes.
    module Node
      
      # Normal nodes can't be the roots of trees.
      def root?
        false
      end
      
      # Normal nodes aren't leaves
      def leaf?
        false
      end
    end
    
    # Leaves cannot have further nodes attached to them, and cannot root
    # selector trees. When a tree is serialised, it is the leaf nodes which
    # are the ultimate objects of serialisation, where the recursive process
    # ends.
    module Leaf
      include Node
      
      # Leaves are leaves.
      def leaf?
        true
      end
    end
    
    # Rules are namespaced by their place in a selctor tree.
    class Selector
      include Formattable, Node
      
      attr_reader :nodes
      
      def initialize(selector)
        accept_format(/\s*/m, "\n")
        
        @scope = selector
        @nodes = []
      end
            
      # Return the child node at the given index.
      def [](index)
        @nodes[index]
      end
      
      # Replace an existing child node.
      def []=(index, node)
        raise ArgumentError,
          "#{node.inspect} is not a node." unless node.is_a?(Tree::Node)
        
        unless node.root?
          @nodes[index] = node
        else
          raise ArgumentError, "Root nodes cannot be added to trees."
        end
      end
      
      # Append a child node.
      def <<(node)
        raise ArgumentError,
          "#{node.inspect} is not a node." unless node.is_a?(Tree::Node)
        
        unless node.root?
          @nodes << node
        else
          raise ArgumentError, "Root nodes cannot be added to trees."
        end
      end
      
      # Remove a child node.
      def delete(node)
        @nodes.delete(node)
      end
      
      # Recursively serialises a selector tree.
      def to_s(scope = "")
        return "" if @nodes.empty?
        scope = scope.empty? ? @scope : scope + " " + @scope
        @nodes.map {|node| node.to_s(scope) }.join(@format)
      end
      
      # Return a node's child nodes.
      def to_a
        nodes
      end
      
      # Recursively return all the rules in a selector tree.
      def rules
        leaves(Rule)
      end
      
      # Recursively return all the leaves of any, or a given type in a selector
      # tree.
      def leaves(type = nil)
        @nodes.inject([]) do |rules, node|
          if node.leaf?
            rules << node if type.nil? || node.is_a?(type)
          elsif node.is_a?(Selector)
            rules.concat(node.rules)
          end
          
          rules
        end
      end
    end
    
    # Eventual replacement for the core Stylesheet class.
    class Stylesheet < Tree::Selector
      
      def initialize
        accept_format(/\s*/m, "\n")
        @nodes = []
      end

      def root?
        true
      end

      def to_s
        return "" if @nodes.empty?
        @nodes.map {|node| node.to_s }.join(@format)
      end
    end
    
    # Eventual replacement for the core Rule class.
    class Rule
      include Formattable, Leaf
      
      attr_reader :selectors, :declarations
      
      def initialize(selectors, *declarations)
        accept_format(/^\s*%s\s*\{\s*%s\s*\}\s*$/m, "%s {%s}")
        
        @selectors = selectors.inject(Selectors.new) do |ss, s|
          ss << s
        end
        
        @declarations = declarations.inject(Declarations.new) do |ds, d|
          ds << d
        end
      end
      
      def to_s(scope = "")
        selectors = @selectors.map {|s| scope + " " + s.to_s }
        sprintf(@format, selectors.join, @declarations.join)
      end
    end
    
  end
end
