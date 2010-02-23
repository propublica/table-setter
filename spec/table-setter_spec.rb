require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TableSetter::Table do
  before :all do
    @table = TableSetter::Table.new("test")
  end
  
  it "should load from a google key" do
    @table.data.should_not be_nil
    @table.data.headers.should_not be_nil
  end
  
  it "should load from a google key" do
    @table.data.should_not be_nil
  end
  
  it "should report the style for a header" do
    @table.data.rows[0].column_for('Bank').style.should eql 'text-align:left;'
  end
end
