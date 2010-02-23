$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'table_setter'
require 'spec'
require 'spec/autorun'
TableSetter.configure(File.dirname(__FILE__))
Spec::Runner.configure do |config|
  
end
