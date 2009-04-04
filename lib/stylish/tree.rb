module Stylish
  module Tree
    
    # Rules are namespaced by their place in a selctor tree.
    class Selector
      
      def initialize(selector)
        @scope = selector
        @nodes = []
      end
      
      # Selectors are not leaves.
      def leaf?
        false
      end
      
      # Return the child node at the given index.
      def [](index)
        @nodes[index]
      end
      
      # Replace an existing child node.
      def []=(index, node)
        if node.is_a?(Tree::Selector) || node.leaf?
          @nodes[index] = node
        else
          raise ArgumentError, "#{node.inspect} is not a node."
        end
      end
      
      # Append a child node.
      def <<(node)
        if node.is_a?(Tree::Selector) || node.leaf?
          @nodes << node
        else
          raise ArgumentError, "#{node.inspect} is not a node."
        end
      end
      
      # Remove a child node.
      def delete(node)
        @nodes.delete(node)
      end
      
      # Recursively serialises the tree of selectors.
      def to_s(scope = "")
        return "" if @nodes.empty?
        scope = scope.empty? ? @scope : scope + " " + @scope
        @nodes.map {|node| node.to_s(scope) }.join("\n")
      end
    end
    
    # Leaves cannot have further nodes attached to them, and cannot root
    # selector trees. When a tree is serialised, it is the leaf nodes which
    # are the ultimate objects of serialisation, where the recursive process
    # ends.
    module Leaf
      
      # Leaves are leaves.
      def leaf?
        true
      end
    end
    
    class Rule
      include Leaf
      
      def to_s(scope = "")
        scope + " {}"
      end
    end
    
  end
end
