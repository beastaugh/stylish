module Stylish
  
  module Extensions
    
    class ColorParser < DeclarationsParser
      parses :color
      
      def parse(state)
        return state unless state.nil?
        
        if Generate.includes_symbols? @value
          val = Generate::Variable.new(@value, Color)
        else
          val = Color.new(@value)
        end
        
        Declaration.new("color", val)
      end
    end
    
  end
end
