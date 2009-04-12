module Stylish
  
  # The objects defined in the Tree module allow for the creation of nested
  # trees of selector scopes. These intermediate data structures can be used to
  # help factor out some of the repetitiveness of CSS code, and can be easily
  # serialised to stylesheets.
  module Tree
        
    # Stylish trees are formed from nodes. The Node module provides a common
    # interface for node objects, whether they be selectors, rules etc.
    module Node
      
      # Normal nodes can't be the roots of trees. Root nodes act differently
      # when serialising a tree, and hence cannot be added as child nodes.
      def root?
        false
      end
      
      # Normal nodes aren't leaves. Leaves must override this method in order
      # to be treated appropriately by other objects in the tree.
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
    
    # Rules are namespaced by their place in a selector tree.
    class SelectorScope
      include Formattable, Node
      
      attr_reader :nodes
      
      def initialize(selector)
        accept_format(/\s*/m, "\n")
        
        @scope = Selector.new(selector)
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
      
      # Recursively serialise the selector tree.
      def to_s(scope = "")
        return "" if @nodes.empty?
        scope = scope.empty? ? @scope.to_s : scope + " " + @scope.to_s
        @nodes.map {|node| node.to_s(scope) }.join(@format)
      end
      
      # Return the node's child nodes.
      def to_a
        nodes
      end
      
      # Recursively return all the rules in the selector tree.
      def rules
        leaves(Rule)
      end
      
      # Recursively return all the comments in the selector tree.
      def comments
        leaves(Comment)
      end
      
      # Recursively return all the leaves of any, or a given type in a selector
      # tree.
      def leaves(type = nil)
        @nodes.inject([]) do |leaves, node|
          if node.leaf?
            leaves << node if type.nil? || node.is_a?(type)
          else
            leaves.concat(node.leaves(type))
          end
          
          leaves
        end
      end
    end
    
  end
end
