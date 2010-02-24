require 'sinatra/static_assets'
require 'sinatra/url_for'

module TableSetter
  class App < Sinatra::Base
    helpers Sinatra::UrlForHelper
    register Sinatra::StaticAssets
    
    set :root, TableSetter.config_path
    # serve static files from the public directory
    enable :static
    set :app_file, __FILE__

    not_found do
      show :"404"
    end
    
    error do
      show :"500"
    end
    
    get "/" do
      headers['Cache-Control'] = "public, max-age=#{TableSetter::App.cache_timeout}"
      last_modified Dir[TableSetter.table_path + "/*.yml"].inject do |memo, obj|
        memo_time = File.new(File.expand_path memo).mtime
        obj_time = File.new(File.expand_path obj).mtime
        return memo_time if memo_time > obj_time 
        obj_time
      end
      show :index, :tables => Table.all
    end
    
    get "/:slug" do
      headers['Cache-Control'] = "public, max-age=#{TableSetter::App.cache_timeout}"
      not_found unless Table.exists? params[:slug]
      table = Table.new(params[:slug], :defer => true)
      last_modified table.updated_at
      table.load
      show :table, :table => table
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