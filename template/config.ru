#!/usr/bin/env ruby

# This is the rackup file for TableSetter, you can use it to run the application through any rack
# enabled web server.
#
# For example this will spin up a thin instance:
# 
# thin start -R ./config.ru
# 
# To run it in apache you should have Passenger enabled, and follow the instructions in the 
# passenger docs:
#
# http://www.modrails.com/documentation/Users%20guide.html#_deploying_a_rack_based_ruby_application

require 'rubygems'
require 'table_setter'
TableSetter.configure(File.dirname(__FILE__))


# You should probably enable Rack::Cache if you're not behind a caching proxy, by uncommenting the
# lines below:
#
#require 'rack/cache'
#use Rack::Cache,
#  :verbose     => true,
#  :metastore   => "file:#{::File.expand_path ::File.dirname(__FILE__)}/meta",
#  :entitystore => "file:#{::File.expand_path ::File.dirname(__FILE__)}/body"
#
# You can tweak the cache timeout for TableSetter by setting the timeout variable on
# TableSetter::App: 
#
#TableSetter::App.cache_timeout = 60 * 15 # 15 minutes
#
run TableSetter::App
