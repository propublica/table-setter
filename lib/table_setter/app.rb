
require 'sinatra/static_assets'
require 'sinatra/url_for'

module TableSetter
  class App < Sinatra::Base
    helpers Sinatra::UrlForHelper
    register Sinatra::StaticAssets
    
    set :root, TableSetter.config_path
    # serve static files from the public directory
    enable :static
    
    
    get "/" do
      Tables.all(TableSetter.table_path)
    end
    
    
    get "/:slug" do
      Table.new(TableSetter.table_path + slug + yaml)
    end
   
  end
end