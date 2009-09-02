module Stylish
  
  class Percentage
    PCTSTR = /-?(0\.)?\d+%/
    
    def initialize(value)
      value = value[0..-2]
      
      if value =~ /^\d+$/
        @number = value.to_i
      else
        @number = value.to_f
      end
    end
    
    def to_s(symbols = {}, scope = "")
      @number.to_s + "%"
    end
    
    def self.match?(value)
      value =~ /^#{PCTSTR}$/
    end
  end
  
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
    
    def to_s(symbols = {}, scope = "")
      self.value.to_s + self.unit
    end
  end
  
  class Position
    HORIZONTAL = %w{left center right}
    VERTICAL   = %w{top middle bottom}
    
    attr_reader :x, :y
    
    def initialize(xpos, ypos)
      self.x = xpos || "center"
      self.y = ypos || "middle"
    end
    
    def x=(xpos)
      if HORIZONTAL.include?(xpos) || xpos.to_i == 0
        @x = xpos
      elsif Percentage.match? xpos
        @x = Percentage.new(xpos)
      else
        @x = Length.new(xpos)
      end
    end
    
    def y=(ypos)
      if VERTICAL.include?(ypos) || ypos.to_i == 0
        @y = ypos
      elsif Percentage.match? ypos
        @y = Percentage.new(ypos)
      else
        @y = Length.new(ypos)
      end
    end
    
    def to_s(symbols = {}, scope = "")
      @x.to_s + " " + @y.to_s
    end
  end
  
end
