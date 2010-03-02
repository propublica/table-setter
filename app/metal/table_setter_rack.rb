# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
TableSetter.configure File.dirname(__FILE__)

require 'rack'
require 'rack/showexceptions'
require 'rack/commonlogger'
require 'rack/lint'

TableSetterRack = Rack::Builder.app do 
  use Rack::CommonLogger, STDERR
  use Rack::ShowExceptions if Rails.env == 'development'
  use Rack::Lint if Rails.env == 'development'
  use(Rack::Cache, 
    :verbose     => true,
    :metastore   => "file:#{RAILS_ROOT}/rack/cache/meta",
    :entitystore => "file:#{RAILS_ROOT}/rack/cache/body") if Rails.env == 'production'
  map "/" do
    run TableSetter::App
  end
end