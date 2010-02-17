require 'open-uri'
require 'fastercsv'
require 'table_fu'

class Table < TableFu
  attr_reader :data, :table_opts, :facets

  def initialize(yaml, opts={:defer => false})
    @opts = YAML.load_file(yaml)
    @table_opts = @opts['table']
    @table_opts.symbolize_keys!
    @slug = File.basename(yaml)
    @deferred = opts[:defer]
    if !@deferred
      self.load
    end
  end
  
  def per_page
    @table_opts[:per_page] || 250
  end
  
  def load
    csv_data = open(@table_opts[:url]).read
    @data = TableFu.new(FasterCSV.parse(csv_data))
    @data.col_opts = @table_opts[:column_options].symbolize_keys! if @table_opts[:column_options]
    if @opts['faceting']
      @opts['faceting']['facet_by']
      @facets = @data.faceted_by @opts['faceting']['facet_by']
    end
  end
  
  def faceted?
    !@facets.nil?
  end
  
  def method_missing(method)
    if @table_opts.include?(method)
      @table_opts[method]
    end
  end
  
  class << self
    def all(dir="config/tables/")
      tables=[] 
      Dir.glob("#{dir}*.{yaml,yml}").each { |file|
        begin
          t = PropublicaTableFu.new(file, :defer => true) 
          tables << t if t.live
        rescue ArgumentError => boom
          RAILS_DEFAULT_LOGGER.error("Error parsing configuration file. #{file}" + boom)
        rescue Exception => boom
          RAILS_DEFAULT_LOGGER.error("Error parsing configuration file. #{file}" + boom)
        end
      }
      tables
    end
    
    def load_table(slug)
      begin
        config = YAML.load_file("config/tables/#{slug}.yaml")
        table = config['table']
        table['slug'] = slug
      rescue ArgumentError => boom
        RAILS_DEFAULT_LOGGER.error("Error parsing configuration file." + boom)
        render "#{RAILS_ROOT}/public/500.html", :status => 500 and return  
      rescue Errno::ENOENT
        render "#{RAILS_ROOT}/public/404.html", :status => 404 and return
      end
      table
    end
  end
end


class TableFu::Formatting
  extend ActionView::Helpers::NumberHelper
  
  class << self
    def currency(num)
      number_to_currency(num)
    end
  end
  
end