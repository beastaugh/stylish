require 'pathname'
require 'mathn'
require 'rational'

module Stylish
  STYLISH_PATH = File.expand_path(File.dirname(__FILE__)) + '/stylish/'
  
  require STYLISH_PATH + 'formattable'
  require STYLISH_PATH + 'tree'
  require STYLISH_PATH + 'core'
  require STYLISH_PATH + 'numeric'
  require STYLISH_PATH + 'extended'
  require STYLISH_PATH + 'color'
  require STYLISH_PATH + 'generate'
  
  class UndefinedVariable < ArgumentError; end
end
