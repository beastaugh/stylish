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
    
    # Write the stylesheet to disk.
    #
    # File names and directories can both be used as arguments. If a file name
    # is used, the stylesheet will be written to that file. If a directory name
    # is used, the stylesheet's name (plus a .css file extension) will be
    # joined to the directory path and the file at the resultant path will be
    # written to.
    #
    # Alternatively, if no argument is provided, the method will simply use the
    # stylesheet name, followed by a .css file extension, as the path of the
    # file to be written to.
    def write(file_or_dir = nil)
      if file_or_dir.nil? || file_or_dir.empty?
        path = Pathname.new(self.name + ".css")
      else
        path = Pathname.new(file_or_dir)
      end
      
      path += self.name + ".css" if path.directory?
      
      File.open(path, "w+") do |f|
        f.write(self)
      end
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
      
      def subsheet(name = nil, selectors = nil, declarations = nil, options = {}, &block)
        subsheet = Stylesheet.new(name, selectors, declarations,
                                  options.merge({:parent => @sheet,
                                                 :depth => @sheet.depth + 1,
                                                 :indent => @sheet.indent}),
                                  &block)
        @sheet.content << subsheet
        subsheet
      end
      
      def comment(*args, &block)
        if args && block
          subsheet = Stylesheet.new(nil, nil, nil, {:parent => @sheet,
                                                    :depth => @sheet.depth + 1,
                                                    :indent => @sheet.indent})
          subsheet.comment(*args)
          self.class.new(subsheet).instance_eval(&block)
          @sheet.content << subsheet
          subsheet
        else
          @sheet.comment(*args)
        end
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
      
      private
      
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
