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
      show :index, :tables => Table.all
    end
    
    
    get "/:slug" do
      show :table, :table => Table.new(params[:slug])
    end
   

    private
    
    def show(page, locals)
      erb page, {:layout => true}, locals
    end
  end
end