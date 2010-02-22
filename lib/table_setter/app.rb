
require 'sinatra/static_assets'
require 'sinatra/url_for'

module TableSetter
  class App < Sinatra::Base
    helpers Sinatra::UrlForHelper
    register Sinatra::StaticAssets
    
    set :root, ROOT
    # serve static files from the public directory
    enable :static
    
    
    get "/" do
      last_modified :
      TableSetter.table_files.map do |yml|
        
      end
      
    end
    
    
    get "/:slug/:page" do
            
    end
   
  end
end