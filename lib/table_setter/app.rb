require 'sinatra/static_assets'
require 'sinatra/url_for'

module TableSetter
  class App < Sinatra::Base
    helpers Sinatra::UrlForHelper
    register Sinatra::StaticAssets
    set :root, TableSetter.config_path
    # serve static files from the public directory
    enable :static
    # set :app_file, __FILE__

    not_found do
      show :"404"
    end
    
    error do
      show :"500"
    end
    
    get "/" do
      headers['Cache-Control'] = "public, max-age=#{TableSetter::App.cache_timeout}"
      last_modified Table.fresh_yaml_time
      show :index, :tables => Table.all
    end
    
    get "/:slug" do
      headers['Cache-Control'] = "public, max-age=#{TableSetter::App.cache_timeout}"
      not_found unless Table.exists? params[:slug]
      table = Table.new(params[:slug], :defer => true)
      last_modified table.updated_at
      table.load
      page = params[:page] || 1
      table.paginate! page
      show :table, :table => table, :page => page
    end
    
    private
    
    def show(page, locals={})
      erb page, {:layout => true}, locals
    end
    
    class << self
      attr_accessor :cache_timeout

      def cache_timeout
        @cache_timeout || 0
      end
      
    end
  end
end