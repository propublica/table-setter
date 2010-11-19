require 'spec_helper'


describe TableSetter::App, "in the application" do
  include Rack::Test::Methods

  def app
    TableSetter::App
  end


  it "should render the homepage" do
    get '/'
    last_response.body.include?("All Tables").should be_true
  end


  it "should render a table" do
    get '/example/'
    last_response.ok?.should be_true
    last_response.body.include?("Failed Banks List").should be_true
  end

end