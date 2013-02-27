require File.expand_path(File.dirname(__FILE__) + '/test_helper')

describe TableSetter::Table do
  it 'should return the latest yaml modification time' do
    `touch #{TableSetter::Table.table_path('example')}`
    assert_equal TableSetter::Table.fresh_yaml_time,
                 File.new(TableSetter::Table.table_path('example')).mtime
  end
end

describe TableSetter::Table do
  before do
    @table = TableSetter::Table.new("example_local")
  end

  it "should load from a google key, and defer loading when asked" do
    table = TableSetter::Table.new("example", :defer => true)
    assert_equal table.data, nil
    table.load
    assert !table.data.nil?
    assert !table.data.headers.nil?
  end

  it 'should be able to find out if a given table exists' do
    assert TableSetter::Table.exists?("non_existent_table") == false
    assert TableSetter::Table.exists?("example")
  end

  it "should have a slug" do
    assert_equal @table.slug, "example_local"
  end

  it "should have a deck" do
    assert !@table.deck.nil?
  end

  it "should have 250 items per page" do
    assert_equal @table.per_page, 250
  end

  it "should be sortable" do
    assert_equal @table.sortable?, false
  end

  it "should have a footer" do
    assert !@table.footer.nil?
  end

  it "should have a title" do
    assert !@table.title.nil?
  end

  it "should have 5805 rows" do
    assert_equal @table.data.rows.length, 5805
  end

  it "should be stylish" do
    assert_equal @table.data.rows[1].column_for('State').style, 'text-align:left;'
    assert_equal @table.data.rows[1].column_for('Project Description').style, 'text-align:right;'
  end

  it "should have stylish headers" do
    assert_equal @table.data.headers[0].style, 'text-align:left;'
    assert_equal @table.data.headers[4].style.length, 0
  end

  it "should be formatted" do
    assert_equal @table.data.rows[1].column_for('ARRA Funds Obligated').to_s, '$154,446'
  end

end


describe TableSetter::Table, "with hard pagination" do
  before do
    @data = TableSetter::Table.new("example_local")
  end

  it "should not be sortable" do
    assert_equal @data.sortable?, false
  end

  it "should be paginated" do
    assert_equal @data.hard_paginate?, true
  end

  it "should paginate based on a page" do
    @data.paginate! 3
    assert_equal @data.page, 3
    assert_equal @data.prev_page, 2
    assert_equal @data.next_page, 4
    assert_equal @data.data.rows.length, @data.per_page
    assert_equal @data.data.rows[0].column_for('State').to_s, 'CALIFORNIA'
  end

  it 'should not paginate when given a bad value' do
    assert_raises(ArgumentError) {@data.paginate!(-1)}
    assert_raises(ArgumentError) {@data.paginate!(10000000)}
  end

  it 'should handle first page' do
    @data.paginate! 1
    assert_equal @data.page, 1
    assert_equal @data.prev_page, nil
  end

  it 'should handle last page' do
    @data.paginate! @data.total_pages
    assert_equal @data.page, @data.total_pages
    assert_equal @data.next_page, nil
  end
end


describe TableSetter::Table, "with faceting and macros" do
  before do
    @data = TableSetter::Table.new("example_faceted")
    @tables = @data.facets
  end

  it 'should load a faceted_table' do
    data = TableSetter::Table.new("example_faceted", :defer=> true)
    assert data.facets.nil?
    data.load
    tables = data.facets
    assert_equal tables.length, 56
  end

  it "should be faceted" do
    assert @data.faceted?
  end

  it "should not be sortable" do
    assert_equal @data.sortable?, false
  end


  it "should have 3 tables" do
    assert_equal @tables.length, 56
  end

  it "should have $212,774,529 for Alabama" do
    assert_equal @tables[0].total_for('Total Appropriation').to_s, '$212,774,529'
  end

  it "should have $416,075,044 for North Carolina with dead row" do
    assert_equal @tables[35].total_for('Total Appropriation').to_s, '$423,318,645'
  end
end

describe TableSetter::Table, "group fetchers" do
  it "should return live tables" do
    assert_equal TableSetter::Table.all.length, 1
  end
end

describe TableSetter::Table, "with urls and google bars" do
  before do
    @table = TableSetter::Table.new("example_formatted")
  end

  it "should have a link row" do
    assert_equal @table.data.rows[1].column_for('Agency Webpage').to_s, "<a href=\"http://www.hhs.gov/recovery/\" title=\"Health and Human Services\">Health and Human Services</a>"
  end

  it 'should show a bar' do
    assert_equal @table.data.rows[1].column_for('Spent (%)').to_s, "<div class=\"bar\" style=\"width:42.0%\">42.0%</div>"
  end
end



