require 'curb'
require 'fastercsv'
require 'table_fu'
require 'net/http'

module TableSetter
  class Table
    attr_reader :data, :table_opts, :facets, :prev_page, :next_page, :page

    def initialize(slug, opts={:defer => false})
      options = indifferent_access YAML.load_file(Table.table_path(slug))
      @table_opts = options[:table]
      @table_opts[:slug] = slug
      @deferred = opts[:defer]
      if !@deferred
        self.load
      end
    end
    
  
    def load
      csv = csv_data
      @data = TableFu.new(csv_data, @table_opts[:column_options] || {})
      if @table_opts[:faceting]
        @data.col_opts[:ignored] = [@table_opts[:faceting][:facet_by]]
        @facets = @data.faceted_by @table_opts[:faceting][:facet_by]
      end
      @data.delete_rows! @table_opts[:dead_rows] if @table_opts[:dead_rows]
    end
    
    
    def csv_data
      case
      when google_key then Curl::Easy.perform(uri).body_str
      when file then File.open(uri).read
      end
    end
  
    def uri
      case 
      when google_key then "http://spreadsheets.google.com/pub?key=#{google_key}&output=csv"
      when file then File.expand_path("#{TableSetter.table_path}#{file}")
      end
    end
    
    def updated_at
      csv_time = google_key.nil? ? file_modification_time(uri) : google_modification_time
      (csv_time > yaml_time ? csv_time : yaml_time).to_s
    end
  
    def faceted?
      !@facets.nil?
    end
    
    def sortable?
      !faceted? && !hard_paginate?
    end
    
    def hard_paginate?
      @table_opts[:hard_paginate] == true
    end
    
    def per_page
      @table_opts[:per_page] || 20
    end
    
    def paginate!(curr_page)
      return if !hard_paginate?
      @page = curr_page.to_i
      raise ArgumentError if @page < 1 || @page > total_pages
      adj_page = @page - 1 > 0 ? @page - 1 : 0 
      @prev_page = adj_page > 0 ? adj_page : nil
      @next_page = page < total_pages ? (@page + 1) : nil
      @data.only!(adj_page * per_page..(@page * per_page - 1))
    end
    
    def total_pages
      @total_pages ||= (@data.rows.length / per_page.to_f).ceil
    end
    
    def sort_array
      @data.sorted_by.inject([]) do |memo, (key, value)|
        memo << [@data.columns.index(key), value == 'descending' ? 0 : 1]
      end
    end
    
    def method_missing(method)
      if @table_opts[method]
        @table_opts[method]
      end
    end
    
  private
    # Returns the google modification time of the spreadsheet. The public urls don't set the
    # last-modified header on anything, so we have to do a little dance to find out when exactly 
    # the spreadsheet was last modified. The od[0-9] part of the feed url changes at whim, so we'll 
    # need to keep an eye on it. Another propblem is that curb doesn't like to parse headers, so
    # since this is a lightweight query from google we can get away with using Net:HTTP
    # If for whatever reason the google modification time is busted we'll return the beginning of
    # time, and rely on the yaml updated time.
    def google_modification_time
      url = URI.parse "http://spreadsheets.google.com/feeds/list/#{google_key}/od7/public/basic"
      resp = nil
      Net::HTTP.start(url.host, 80) do |http|
        resp = http.head(url.path)
        #http.readbody = false
      end
      resp['Last-Modified'].nil? ? Time.at(0) : Time.parse(resp['Last-Modified'])
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
          table = new(File.basename(file, ".yml"), :defer => true)
          tables << table if table.live
        end
        tables
      end
      
      def fresh_yaml_time
        newest_file = Dir["#{TableSetter.table_path}/*.yml"].inject do |memo, obj|
          memo_time = File.new(File.expand_path memo).mtime
          obj_time = File.new(File.expand_path obj).mtime
          if memo_time > obj_time
            memo
          else 
            obj
          end
        end
        File.new(newest_file).mtime
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

class TableFu::Formatting
  class << self
    def bar(percent)
      percent = percent.to_f
      if percent < 1
        percent = percent * 100
      end
      "<div class=\"bar\" style=\"width:#{percent}%\">#{percent}%</div>"
    end
  end
end



