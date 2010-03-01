# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
TableSetter.configure File.dirname(__FILE__)
class TableSetterRack < TableSetter::App
end
