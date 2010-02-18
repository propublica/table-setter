$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

# Gems
require 'rubygems'
gem 'sinatra'
gem 'thin'
gem 'table-fu'
gem 'sinatra-static-assets'
gem 'emk-sinatra-url-for'

require 'table-fu'
require 'yaml'


autoload :Sinatra,  'sinatra/base'
autoload :Thin,     'thin'
autoload :ERB,      'erb'

module TableSetter
  # autoload internals
  autoload :App,         'table_setter/app'
  autoload :CommandLine, 'table_setter/command_line'
  
  ROOT = File.expand_path(File.dirname(__FILE__) + "/..")
  
  class << self
    attr_reader :config_path
    
    def configure(path)
      @config_path =  File.expand_path(File.dirname(path))
    end
    
  end
end