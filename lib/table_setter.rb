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
  autoload :Table,   'table_setter/table'
  
  ROOT = File.expand_path(File.dirname(__FILE__) + "/..") unless defined? ROOT
  
  class << self
    attr_reader :config_path
    
    def configure(path)
      @config_path = File.expand_path(path)
    end
    
    def table_path
      @config_path + "/tables/"
    end
    
  end
end