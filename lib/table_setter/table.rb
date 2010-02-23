require 'open-uri'
require 'fastercsv'
require 'table_fu'

module TableSetter
  class Table
    attr_reader :data, :table_opts, :facets

    def initialize(slug, opts={:defer => false})
      @opts = YAML.load_file(Table.table_path(slug))
      @table_opts = @opts[:table]
      @table_opts[:slug] = slug
      @deferred = opts[:defer]
      if !@deferred
        self.load
      end
    end
    

    def per_page
      @table_opts[:per_page] || 250
    end
  
    def load
      csv_data = open(uri).read
      @data = TableFu.new(csv_data, @table_opts[:column_options] || {})
      if @opts[:faceting]
        @opts[:faceting][:facet_by]
        @facets = @data.faceted_by @opts[:faceting][:facet_by]
      end
    end
  
    def uri
      "http://spreadsheets.google.com/pub?key=#{key}&output=csv" || file
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
      def all
        tables=[] 
        Dir.glob("#{TableSetter.table_path}/*.yml").each do |file|
          t = new(File.basename(file, ".yml"), :defer => true)
          tables << t if t.live
        end
        tables
      end
    
      def table_path(slug)
        "#{TableSetter.table_path}#{slug}.yml"
      end

    end

  end
end

class TableFu::Formatting  
  class << self
    def currency(num)
      number_to_currency(num)
    end
  end
end