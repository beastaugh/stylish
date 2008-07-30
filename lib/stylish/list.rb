module Stylish
  
  class List
    
    def initialize()
    end
    
    def gobble(directory, &block)
      @files ||= []
      
      Find.find(directory) do |path|
        if FileTest.directory?(path)
          if File.basename(path)[0] == ?.
            Find.prune # Ignore system directories
          else
            next
          end
        elsif path =~ /\.(css)$/
          @files << Doc.chew(path)
        end
      end
      
      yield(@files)
      
      return @files
    end
    
    def self.gobble(directory, &block)
      List.new.gobble(directory, &block)
    end
  end
  
end
