# encoding: utf-8
require 'curb'
require 'table_fu'
require 'net/http'

module TableSetter
  class Table
    # The +Table+ class handles processing the yaml processing and csv loading,
    # through table fu
    attr_reader :data, :table_opts, :facets, :prev_page, :next_page, :page

    # A new Table should accept a slug, mapped to a yaml in the tables directory,
    # optionally you can defer loading of the table until you're ready to render it.
    def initialize(slug, opts={:defer => false})
      options = indifferent_access YAML.load_file(Table.table_path(slug))
      @table_opts = options[:table]
      @table_opts[:slug] = slug
      @deferred = opts[:defer]
      if !@deferred
        self.load
      end
    end

    # The load method handles the actual request either to the file system or remote url.
    # It performs the requested data manipulations form the yml file after the data has been loaded.
    # We're keeping this explicit to control against unnecessary http requests.
    def load
      csv = csv_data
      if @table_opts[:column_options]
        @table_opts[:column_options]['style'] ||= {}
      end
      @data = TableFu.new(csv_data, @table_opts[:column_options] || {})
      if @table_opts[:faceting]
        @data.col_opts[:ignored] = [@table_opts[:faceting][:facet_by]]
        @facets = @data.faceted_by @table_opts[:faceting][:facet_by]
      end
      @data.delete_rows! @table_opts[:dead_rows] if @table_opts[:dead_rows]
    end

    # The csv_data for the table fu instance is loaded either from the remote source or from a local
    # file, depending on the keys present in the yaml file.
    def csv_data
      case
      when google_key || url then Curl::Easy.perform(uri).body_str
      when file then File.open(uri).read
      end
    end

    # Returns a usable uri based on what sort of input we have.
    def uri
      case
      when google_key then "http://spreadsheets.google.com/pub?key=#{google_key}&output=csv"
      when url then url
      when file then File.expand_path("#{TableSetter.table_path}#{file}")
      end
    end

    # The real +updated_at+ of a Table instance is the newer modification time of the csv file or
    # the yaml file. Updates to either resource should break the cache.
    def updated_at
      csv_time = google_key.nil? ? modification_time(uri) : google_modification_time
      (csv_time > yaml_time ? csv_time : yaml_time).to_s
    end

    def faceted?
      !@facets.nil?
    end

    # A table isn't sortable by tablesorter if it's either faceted or multi-page paginated.
    def sortable?
      !faceted? && !hard_paginate?
    end

    # hard_paginate instructs the app to render batches of a table.
    def hard_paginate?
      @table_opts[:hard_paginate] == true
    end

    # The number of rows per page. Defaults to 20
    def per_page
      @table_opts[:per_page] || 20
    end

    # paginate uses TableFu's only! method to batch the table. It also computes the page attributes
    # which are nil and meaningless otherwise.
    def paginate!(curr_page)
      return if !hard_paginate?
      @page = curr_page.to_i
      raise ArgumentError if @page < 1 || @page > total_pages
      adj_page = @page - 1 > 0 ? @page - 1 : 0
      @prev_page = adj_page > 0 ? adj_page : nil
      @next_page = page < total_pages ? (@page + 1) : nil
      @data.only!(adj_page * per_page..(@page * per_page - 1))
    end


    # The total pages we'll have. We need to calculate it before paginate, so that we still have the
    # full @data.rows.length
    def total_pages
      @total_pages ||= (@data.rows.length / per_page.to_f).ceil
    end

    # A convienence method to return the sort array for table setter.
    def sort_array
      if @data.sorted_by
        @data.sorted_by.inject([]) do |memo, (key, value)|
          memo << [@data.columns.index(key), value == 'descending' ? 1 : 0]
        end
      end
    end

    # We magically need access to the top level keys like google_key, or uri for the other methods.
    # It's a bit dangerous because everything returns nil otherwise. At some point we should eval
    # and create methods at boot time.
    def method_missing(method)
      if @table_opts[method]
        @table_opts[method]
      end
    end

  private

    # Returns the google modification time of the spreadsheet. The public urls don't set the
    # last-modified header on anything, so we have to do a little dance to find out when exactly
    # the spreadsheet was last modified. The od[0-9] part of the feed url changes at whim, so we'll
    # need to keep an eye on it. Another problem is that curb doesn't feel like parsing headers, so
    # since a head request from google is pretty lightweight we can get away with using Net:HTTP.
    # If for whatever reason the google modification time is busted we'll the yaml modified time.
    def google_modification_time
      local_url = URI.parse "http://spreadsheets.google.com/feeds/list/#{google_key}/od6/public/basic"
      web_modification_time local_url
    end

    # Returns the last-modified time from the remote server. Assumes the remote server knows how to
    # do this. Returns the epoch if the remote is dense.
    def web_modification_time(local_url)
      resp = nil
      Net::HTTP.start(local_url.host, 80) do |http|
        resp = http.head(local_url.path)
      end
      resp['Last-Modified'].nil? ? Time.at(0) : Time.parse(resp['Last-Modified'])
    end

    # Dispatches to web_modification_time if we're dealing with a url, otherwise just stats the
    # local file.
    def modification_time(path)
      is_uri = URI.parse(path)
      if !is_uri.host.nil?
        return web_modification_time is_uri
      end
      File.new(path).mtime
    end

    # The modification time of this Table's yaml file.
    def yaml_time
      modification_time(Table.table_path(slug))
    end

    # Enable string or symbol key access to col_opts
    # from sinatra.
    def indifferent_access(params)
      params = indifferent_hash.merge(params)
      params.each do |key, value|
        next unless value.is_a?(Hash)
        params[key] = indifferent_access(value)
      end
    end

    # Duplicate a hash's keys and convert them into symbols.
    def indifferent_hash
      Hash.new {|hash,key| hash[key.to_s] if Symbol === key }
    end

  public

    class << self

      # Returns all the tables in the table directory. Each table is deferred so accessing the @data
      # attribute will throw and error.
      def all
        tables=[]
        Dir.glob("#{TableSetter.table_path}/*.yml").each do |file|
          table = new(File.basename(file, ".yml"), :defer => true)
          tables << table if table.live
        end
        tables
      end

      # +fresh_yaml_time+ checks each file in the tables directory and returns the newest file's
      # modification time -- there's probably a more unix-y way to do this but for now this is
      # plenty speedy.
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

      # Convenience method for looking up by slug.
      def table_path(slug)
        "#{TableSetter.table_path}#{slug}.yml"
      end

      # Does a table with this slug exist?
      def exists?(slug)
        File.exists? table_path(slug)
      end
    end

  end
end

class TableFu::Formatting
  class << self
    # In order to show a sideways bar chart, we're extending the builtin TableFu formatters.
    def bar(percent)
      percent = percent.to_f
      if percent < 1
        percent = percent * 100
      end
      "<div class=\"bar\" style=\"width:#{percent}%\">#{percent}%</div>"
    end
    # markdown formatting in tablefu cells
    def markdown(cell)
      RDiscount.new(cell).to_html
    end

    # format as a link, if the href is empty don't make the link active
    def link(linkname, href)
      title = linkname.to_s.gsub(/(["])/, "'")
      if !href.value.nil? && !href.value.to_s().empty?
        "<a href=\"#{href}\" title=\"#{title}\">#{linkname}</a>"
      else
        "<a title=\"#{title}\">#{linkname}</a>"
      end
    end

    # make it strong
    def strong(cell)
      "<strong>#{cell}</strong>"
    end

    # make it small
    def small(cell)
      "<small>#{cell}</small>"
    end

    # join multiple columns, with optional delimiter
    def join(*args)
      args.join(" ")
    end

    def joinbr(*args)
      args.join("<br>")
    end

    def joincomma(*args)
      args.join(", ")
    end

  end
end
