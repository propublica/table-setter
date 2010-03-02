
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.time_zone = 'UTC'
  config.gem "table_setter"
  config.frameworks -= [:active_record, :action_controller, :action_view, :action_mailer, :active_resource]
end