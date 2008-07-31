module Stylish
  
  class Doc
    
    attr_reader :file, :name, :chewed
    
    def initialize(file)
      @file = file
      @name = File.basename(@file)
      return self
    end
    
    def chew
      @chewed = File.open(@file, "r").read.scan(/\/\*\*(.*?)\*\/(.*?)(\n\n|\z)/m).map do |docs, code|
        docs_a = docs.split(/\n/).map {|s| s.strip.gsub(/^\*\s*/, "")}.delete_if {|s| s.nil? or s.strip.empty?}
        docs_h = {}
        docs_h[:title] = docs_a.first
        docs_h[:notes] = []
        docs_h[:attrs] = {}
        docs_a.shift
        docs_a.map do |line|
          if line =~ /^@\w+$/
            docs_h[:attrs][line.sub(/^@/, "").intern] = true
          elsif line =~ /^@/
            peas = line.split(/\s/, 2)
            docs_h[:attrs][peas[0].sub(/^@/, "").intern] = peas[1]
          else
            docs_h[:notes] << line
          end
        end
        
        { :docs => docs_h, :code => code.strip }
      end
    end
    
    def print(template_file, target_file)
      template = File.open(template_file, "r").read
      rhtml = ERB.new(template)
      
      File.open(target_file, "w") do |target|
        target.puts(rhtml.result(binding))
      end
    end
    
    def self.chew(file)
      doc = Doc.new(file)
      doc.chew
      return doc
    end
  end
  
end
