class TableController < ApplicationController
  caches_page :index, :show
  
  def show
    @table = Table.load(params[:slug])
  end
  
  def index
    @tables = Table.
  end
  
  def expire
    expire_page(:actions => :show, :slug => params[:slug])
    redirect_to :action => 'view'
  end

end