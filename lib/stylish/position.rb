module Stylish
  
  class Length
    UNITS = [
      # Relative length units
      "em", "ex", "px",
      # Absolute length units
      "in", "cm", "mm", "pt", "pc"]
    
    attr_reader :unit, :value
    
    def initialize(value)
      self.unit  = value.match(/(#{UNITS * "|"})$/)[0]
      self.value = value[0..-3]
    end
    
    def value=(value)
      if value.is_a? Numeric
        @value = value
      elsif value =~ /^\d+$/
        @value = value.to_i
      elsif value =~ /^\d+\.\d+$/
        @value = value.to_f
      end
    end
    
    def unit=(unit)
      @unit = unit if UNITS.include? unit
    end
    
    def to_s
      self.value.to_s + self.unit
    end
  end
  
  class Position
    HORIZONTAL = ["left", "center", "right"]
    VERTICAL   = ["top", "center", "bottom"]
    
    attr_reader :x, :y
    
    def initialize(xpos, ypos)
      self.x = xpos || "center"
      self.y = ypos || "center"
    end
    
    def x=(xpos)
      if HORIZONTAL.include?(xpos) || xpos.to_i == 0 || xpos =~ PERCENTAGE
        @x = xpos
      else
        @x = Length.new(xpos)
      end
    end
    
    def y=(ypos)
      if VERTICAL.include?(ypos) || ypos.to_i == 0 || ypos =~ PERCENTAGE
        @y = ypos
      else
        @y = Length.new(ypos)
      end
    end
    
    def to_s(symbols = {}, scope = "")
      @x.to_s + " " + @y.to_s
    end
  end
  
end
