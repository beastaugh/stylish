module Stylish
  
  class Stylesheet < Tree::SelectorScope
    accept_format(/\s*/m, "\n")
    
    # Stylesheets are pure aggregate objects; they can contain child nodes,
    # but have no data of their own. Their initializer therefore accepts no
    # arguments.
    def initialize
      @nodes = []
    end
    
    # Stylesheets are the roots of selector trees.
    def root?
      true
    end
    
    # Recursively serialise the tree to a stylesheet.
    def to_s(symbols = {})
      return "" if @nodes.empty?
      @nodes.map {|node| node.to_s(symbols) }.join(self.class.format)
    end
  end
  
end
