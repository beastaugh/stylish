module Stylish
  
  def self.generate(options = {}, &block)
    dsl = Tree::Description.new
    dsl.instance_eval(&block)
    dsl.node
  end
  
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
      
      # Recursively serialise the selector tree.
      def to_s(scope = "")
        return "" if @nodes.empty?
        scope = scope.empty? ? @scope : scope + " " + @scope
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
      
      # Recursively return all the leaves of any, or a given type in a selector
      # tree.
      def leaves(type = nil)
        @nodes.inject([]) do |rules, node|
          if node.leaf?
            rules << node if type.nil? || node.is_a?(type)
          elsif node.is_a?(SelectorScope)
            rules.concat(node.rules)
          end
          
          rules
        end
      end
    end
    
    # Eventual replacement for the core Stylesheet class.
    class Stylesheet < Tree::SelectorScope
      
      # Stylesheets are pure aggregate objects; they can contain child nodes,
      # but have no data of their own. Their initializer therefore accepts no
      # arguments.
      def initialize
        accept_format(/\s*/m, "\n")
        @nodes = []
      end
      
      # Stylesheets are the roots of selector trees.
      def root?
        true
      end
      
      # Recursively serialise the tree to a stylesheet.
      def to_s
        return "" if @nodes.empty?
        @nodes.map {|node| node.to_s }.join(@format)
      end
    end
        
  end
end
