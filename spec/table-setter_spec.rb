require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TableSetter::Table do
  before :all do
    @table = TableSetter::Table.new("table")
  end
  
  it "should load from a google key, and defer loading when asked" do
    table = TableSetter::Table.new("table", :defer => true)
    table.data.should be_nil
    table.load
    table.data.should_not be_nil
    table.data.headers.should_not be_nil
  end
  
  it 'should be able to find out if a given table exists' do
    TableSetter::Table.exists?("non_existent_table").should be_false
    TableSetter::Table.exists?("table").should be_true
  end
  
  it "should have a slug" do
    @table.slug.should eql "table"
  end
  
  it "should have a deck" do
    @table.deck.should_not be_nil
  end
  
  it "should have 250 items per page" do
    @table.per_page.should eql 250
  end
  
  it "should be sortable" do
    @table.sortable?.should be_true
  end
  
  it "should have a footer" do
    @table.footer.should_not be_nil
  end
  
  it "should have a title" do
    @table.title.should_not be_nil
  end
  
  it "should have 5805 rows" do
    @table.data.rows.length.should eql 5805
  end
  
  it "should be stylish" do
    @table.data.rows[1].column_for('State').style.should eql 'text-align:left;'
    @table.data.rows[1].column_for('Project Description').style.should eql 'text-align:right;'
    @table.data.rows[1].column_for('URL').style.should eql 'text-align:center;'
  end
  
  it "should have stylish headers" do
    @table.data.headers[0].style.should eql 'text-align:left;'
    @table.data.headers[4].style.length.should eql 0
  end
  
  it "should be formatted" do
    @table.data.rows[1].column_for('ARRA Funds Obligated').to_s.should eql '$154,446'
  end

end


describe TableSetter::Table, "with hard pagination" do
  
  before :each do
    @data = TableSetter::Table.new("test")
  end
  
  it "should not be sortable" do
    @data.sortable?.should eql false
  end
  
  it "should be paginated" do
    @data.hard_paginate?.should eql true
  end
  
  it "should paginate based on a page" do
    @data.paginate! 3
    @data.page.should eql 3
    @data.prev_page.should eql 2
    @data.next_page.should eql 4
    @data.data.rows.length.should eql @data.per_page
    @data.data.rows[0].column_for('Bank').to_s.should eql 'Community Bank of West Georgia'    
  end
  
  it 'should not paginate when given a bad value' do
    lambda {@data.paginate!(-1)}.should raise_exception(ArgumentError)
    lambda {@data.paginate!(10000000)}.should raise_exception(ArgumentError)
  end
  
  it 'should handle first page' do
    @data.paginate! 1
    @data.page.should eql 1
    @data.prev_page.should eql nil
  end
  
  it 'should handle last page' do
    @data.paginate! @data.total_pages
    @data.page.should eql @data.total_pages
    @data.next_page.should eql nil
  end
  
end


describe TableSetter::Table, "with faceting and macros" do
  
  before :all do
    @data = TableSetter::Table.new("faceted_table")
    @tables = @data.facets
  end
  
  it 'should load a faceted_table' do
    data = TableSetter::Table.new("faceted_table", :defer=> true)
    data.facets.should be_nil
    data.load
    tables = data.facets
    tables.length.should eql 56 
  end
  
  it "should be faceted" do
    @data.faceted?.should be_true
  end
  
  it "should not be sortable" do
    @data.sortable?.should be_false
  end
  
  
  it "should have 3 tables" do
    @tables.length.should eql 56
  end
  
  it "should have $212,774,529 for Alabama" do
    @tables[0].total_for('Total Appropriation').to_s.should eql '$212,774,529'
  end
  
  it "should have $416,075,044 for North Carolina with dead row" do
    @tables[35].total_for('Total Appropriation').to_s.should eql '$423,318,645'
  end
  
  it "should have a macro formatted link row" do
    @tables[0].rows[1].column_for('URL').to_s.should eql "<a href='http://example.com/1234' title='Sample Link'>Sample Link</a>"
  end
  
end

describe TableSetter::Table, "group fetchers" do
  it "should return live tables" do
    TableSetter::Table.all.length.should eql 1
  end
end