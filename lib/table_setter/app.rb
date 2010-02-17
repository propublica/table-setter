module TableSetter
  class App < Sinatra::Base
    
    set :root, ROOT
    # serve static files from the public directory
    enable :static
    
    
    get "/" do
      last_modified :
      TableSetter.table_files.map do |yml|
        
      end
    end
    
    
    get "/:slug" do
      
    end
   
  end
end