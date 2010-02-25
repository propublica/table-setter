require 'open-uri'
require 'fastercsv'
require 'table_fu'
require 'net/http'

module TableSetter
  class Table
    attr_reader :data, :table_opts, :facets

    def initialize(slug, opts={:defer => false})
      options = indifferent_access YAML.load_file(Table.table_path(slug))
      @table_opts = options[:table]
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
      if @table_opts[:faceting]
        @data.col_opts[:ignored] = [@table_opts[:faceting][:facet_by]]
        @facets = @data.faceted_by @table_opts[:faceting][:facet_by]
      end
    end
  
    def uri
      !google_key.nil? ?
      "http://spreadsheets.google.com/pub?key=#{google_key}&output=csv" : 
      File.expand_path("#{TableSetter.table_path}#{file}")
    end
    
    def updated_at
      csv_time = google_key.nil? ? file_modification_time(uri) : google_modification_time
      (csv_time > yaml_time ? csv_time : yaml_time).to_s
    end
  
    def faceted?
      !@facets.nil?
    end
    
    def sortable?
      !faceted? || !hard_paginate
    end
    
    def hard_paginate
      !(@table_opts[:hard_paginate] == false)
    end
    
    def sort_by
      @table_opts[:sort_by] ? @data.columns.index(@table_opts[:sort_by]) : 0
    end
    
    def sort_order
      @table_opts[:sort_order] == 'descending' ? 0 : 1
    end
    
    def method_missing(method)
      if @table_opts[method]
        @table_opts[method]
      end
    end
    
  private
    
    def google_modification_time
      url = URI.parse "http://spreadsheets.google.com/feeds/list/#{google_key}/od6/public/basic"
      resp = nil
      Net::HTTP.start(url.host, 80) do |http|
        resp = http.head(url.path)
      end
      Time.parse resp['Last-Modified']
    end
    
    def file_modification_time(path)
      File.new(path).mtime
    end
    
    def yaml_time
      file_modification_time(Table.table_path(slug))
    end

    # Enable string or symbol key access to col_opts
    # from sinatra
    def indifferent_access(params)
      params = indifferent_hash.merge(params)
      params.each do |key, value|
        next unless value.is_a?(Hash)
        params[key] = indifferent_access(value)
      end
    end

    def indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end
    
  public
  
    class << self
      def all
        tables=[] 
        Dir.glob("#{TableSetter.table_path}/*.yml").each do |file|
          t = new(File.basename(file, ".yml"), :defer => true)
          tables << t if t.live
        end
        tables
      end
      
      def fresh_yaml_time
        Dir["#{TableSetter.table_path}/*.yml"].inject do |memo, obj|
          memo_time = File.new(File.expand_path memo).mtime
          obj_time = File.new(File.expand_path obj).mtime
          return memo_time if memo_time > obj_time 
          obj_time
        end
      end
      
      def table_path(slug)
        "#{TableSetter.table_path}#{slug}.yml"
      end
      
      def exists?(slug)
        File.exists? table_path(slug)
      end
    end

  end
end
