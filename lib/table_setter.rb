$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'table_fu'
require 'yaml'


autoload :Sinatra,  'sinatra/base'
autoload :Thin,     'thin'
autoload :ERB,      'erb'

module TableSetter
  # autoload internals
  autoload :App,     'table_setter/app'
  autoload :Command, 'table_setter/command'
  
  ROOT = File.expand_path(File.dirname(__FILE__) + "/..")
  
  class << self
    attr_reader :config_path
    
    def configure(path)
      @config_path = File.expand_path(path)
    end
    
    def table_files
      Dir[@config_path + "/tables/**"]
    end
    
  end
end