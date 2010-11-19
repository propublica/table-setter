$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))

require 'table_fu'
require 'yaml'

if RUBY_VERSION > "1.9"
  require 'csv'
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
  ::FasterCSV = CSV unless defined? ::FasterCSV
else
  require 'fastercsv'
end

autoload :Sinatra,   'sinatra/base'
autoload :Thin,      'thin'
autoload :ERB,       'erb'
autoload :Curb,      'curb'
autoload :RDiscount, 'rdiscount'

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