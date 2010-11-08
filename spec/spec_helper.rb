$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'table_setter'
require 'spec'
require 'rack/test'
require 'spec/autorun'
TableSetter.configure(File.join(File.dirname(__FILE__), "..", "template"))
Spec::Runner.configure do |config|

end
