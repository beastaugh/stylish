module Stylish
  
  def self.generate(*args, &block)
    Stylesheet.new(*args, &block)
  end
  
  class Stylesheet
    
    def rule(selectors, declarations)
      @content << Rule.new(selectors, declarations)
    end
    
    def comment(*args)
      @content << Comment.new(*args)
    end
    
    def image(path)
      "url('#{(@images_path + path).to_s}')" if path
    end
    
    class Description
      def initialize(sheet = nil, selectors = nil, declarations = nil)
        @sheet = sheet || Stylesheet.new
        @selectors = selectors
      end
      
      def rule(selectors = nil, *declarations, &block)
        return unless selectors || !declarations.empty?
        selectors = selectors.strip.split(/\s*,\s*/).map do |s|
          @selectors ? "#{@selectors} #{s}" : s
        end
        
        if selectors && !block
          @sheet.rule(selectors, declarations)
        else
          selectors.each do |selector|
            @sheet.rule(selector, declarations) if !declarations.empty?
            self.class.new(@sheet, selector, declarations).instance_eval(&block)
          end
        end
      end
      
      def comment(*args)
        @sheet.comment(*args)
      end
      
      def image(path)
        @sheet.image(path)
      end
      
      def background(options)
        options.merge! :image => @sheet.image(options[:image])
        Background.new(options)
      end
      
      def display(value)
        ["display", value]
      end
      
      def method_missing(name, *args)
        if self.respond_to?(name)
          self.send(name, *args)
        elsif @sheet.respond_to?(name)
          @sheet.send(name, *args)
        elsif name.id2name =~ /^\w+$/
          Stylesheet.send(:define_method, name) do |value|
            [name.id2name.gsub(/_/, "-"), value]
          end
          
          @sheet.send(name, *args)
        end
      end
    end
  end
  
end
