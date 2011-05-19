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
    get '/example_local/'
    last_response.ok?.should be_true
    last_response.body.include?("Browse All Approved Stimulus Highway Projects").should be_true
  end

end