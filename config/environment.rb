
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.frameworks -= [ :active_record, :active_resource, :action_mailer ]
  
  # gems needed
  config.gem "table_fu", :version => '>= 0.0.1'  
  config.gem 'mislav-will_paginate', :version => '>= 2.3.8', :lib => 'will_paginate', 
    :source => 'http://gems.github.com'
    
  config.time_zone = 'UTC'
end