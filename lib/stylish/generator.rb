require 'yaml'

module Stylish
  
  class Generator
    attr_accessor :stylesheets
    
    # Loads the template file and one or more palette files and generates a
    # stylesheet array for each palette, consisting of a number of generated
    # CSS rules which match property names from the template to values from
    # the palettes.
    def initialize(tfile, pdir)
      template = File.open(tfile) {|yf| YAML::load(yf) }
      palettes = {}
      
      Dir.open(pdir).each do |f|
        unless FileTest.directory?(f) || File.basename(f)[0] == ?.
          palettes[f.sub(/\.[a-z]+$/, "")] = File.open(pdir + "/" + f) {|yf| YAML::load(yf) }
        end
      end
      
      generate(template, palettes)
    end
    
    # Prints generated stylesheets to the specified directory. File names will
    # match those of the palette files, so if you have <tt>red.yml</tt> and
    # <tt>blue.yml</tt> palette files, you'll end up with <tt>red.css</tt> and
    # <tt>blue.css</tt> stylesheet files.
    def print(dir)
      @stylesheets.each_pair do |style, rules|
        File.open(dir + "/" + style + ".css", "w+") do |f|
          f.write(rules.join("\n") + "\n")
        end
      end
    end
    
    private
    
    # Generates an array of stylesheets, each of which is an array of rules.
    # Each palette's mappings of names to property values are matched up with
    # the template's mappings of names to selectors and property names. The
    # resulting group of objects can then be easily printed.
    def generate(template, palettes)
      @stylesheets = {}
      palettes.each_pair do |name, mappings|
        ss = []
        
        mappings.each_pair do |n, p|
          s = template[n][0]
          d = Declaration.new(template[n][1], p)
          ss << Rule.new(s, [d])
        end
        
        @stylesheets[name] = ss
      end
      
      self
    end
  end
  
end
