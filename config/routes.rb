ActionController::Routing::Routes.draw do |map|
  map.table ':slug/:page', :controller => 'table', :action => 'view', :requirements => { :page => /\d+/}, :page => nil
  map.connect ':slug/expire', :controller => 'table', :action => 'expire'
  map.root :controller =>'table', :action => 'index'
end