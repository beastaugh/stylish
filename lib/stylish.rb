require 'pathname'
require 'mathn'
require 'rational'

module Stylish
  VERSION = '0.1.6'
  
  STYLISH_PATH = File.expand_path(File.dirname(__FILE__)) + '/stylish/'
  
  require STYLISH_PATH + 'formattable'
  require STYLISH_PATH + 'tree'
  require STYLISH_PATH + 'core'
  require STYLISH_PATH + 'numeric'
  require STYLISH_PATH + 'extended'
  require STYLISH_PATH + 'color'
  require STYLISH_PATH + 'generate'
  require STYLISH_PATH + 'extensions/declarations_parser'
  require STYLISH_PATH + 'extensions/background_parser'
  require STYLISH_PATH + 'extensions/color_parser'
  
  class UndefinedVariable < ArgumentError; end
  class AbstractMethod    < NameError;     end
end
