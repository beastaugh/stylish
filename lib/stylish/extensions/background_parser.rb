module Stylish
  
  module Extensions
    
    class BackgroundParser < DeclarationsParser
      parses :background
      
      def parse(state)
        return state unless state.nil?
        
        if Generate.includes_symbols? @value
          Generate::Variable.new(@value, Background)
        else
          Background.new(@value)
        end
      end
    end
    
  end
end
