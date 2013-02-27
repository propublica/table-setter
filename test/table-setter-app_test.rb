require File.expand_path(File.dirname(__FILE__) + '/test_helper')
require 'rack/test'


describe TableSetter::App, "in the application" do
  include Rack::Test::Methods

  def app
    TableSetter::App
  end

  it "should render the homepage" do
    get '/'
    assert last_response.body.include?("All Tables")
  end

  it "should render a table" do
    get '/example_local/'
    assert last_response.ok?
    assert last_response.body.include?("Browse All Approved Stimulus Highway Projects")
  end
end
