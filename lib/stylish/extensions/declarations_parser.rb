module Stylish
  
  module Extensions
    
    class DeclarationsParser
      @@extensions = []
      
      def initialize(key, value)
        @key, @value = key, value
      end
      
      def parse(state = nil)
        raise AbstractMethod,
          "The parse method must be implemented in a subclass."
      end
      
      def self.applicable?(key = nil, value = nil)
        raise AbstractMethod,
          "The applicable? class method must be implemented in a subclass."
      end
      
      def self.inherited(klass)
        @@extensions << klass
      end
      
      def self.extensions
        @@extensions.reverse
      end
      
      def self.parses(*keys)
        @applicable = keys
        
        def self.applicable?(k = nil, v = nil)
          @applicable.include? k
        end
      end
    end
    
  end
end
