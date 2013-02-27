$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'table_setter'
TableSetter.configure(File.join(File.dirname(__FILE__), "..", "template"))
require 'minitest/autorun'
