require 'optparse'
require 'rack'
require 'rack/showexceptions'
require 'rack/commonlogger'
require 'rack/lint'

module TableSetter
  class Command
    BANNER = <<-EOB
table-setter is a Sinatra application for rendering and processing CSVs from google docs into HTML.

Usage:
  table-setter COMMAND path/to/table-setter/assets OPTIONS

commands:
  start    run the development server, for deployment use config.ru
  install  copy the table-setter assets into the the directory
  build    statically build tables in the ./out/ directory

options:
    EOB


    def initialize
      @prefix = ""
      parse_options
      @prefix = "/#{@prefix}/".gsub(/^\/\//, "/")
      command = ARGV.shift
      @directory = ARGV.shift || '.'
      TableSetter.configure @directory
      case command
      when 'start' then start_server
      when 'install' then install_assets
      when 'build' then build_out
      else puts BANNER
      end
    end

    def start_server
      app = build_rack
      Rack::Handler::Thin.run app, :Port => "3000"
    end

    def install_assets
      FileUtils.mkdir_p @directory unless File.exists? @directory
      puts "\nInstalling TableSetter files...\n\n"
      base_files.each do |path|
        copy_file path, File.join(TableSetter.config_path, path.gsub(ROOT + "/template/", "/"))
      end
    end

    def build_out
      @out_dir = File.join(TableSetter.config_path, 'out', @prefix)
      puts "\nBuilding your TableSetter files...\n\n"
      app = build_rack
      @request = Rack::MockRequest.new(app)
      build_index
      build_assets
      build_tables
    end

    private
    # Option parsing
    def parse_options
      @options = {}
      @option_parser = OptionParser.new do |opts|
        opts.on "-p", "--prefix PREFIX", "url prefix for the export command" do |prefix|
          @prefix = "#{prefix}"
        end
      end
      @option_parser.banner = BANNER
      @option_parser.parse! ARGV
    end

    def build_rack
      prefix = @prefix
      config = File.join(@directory, "config.ru")

      Rack::Builder.app do
        map prefix do
          if(File.exists? config)
            run Rack::Builder.parse_file(config).first
          else
            use Rack::CommonLogger, STDERR
            use Rack::ShowExceptions
            use Rack::Lint
            run TableSetter::App
          end
        end
      end
    end

    def build_index
      build_file("#{@prefix}", "index.html")
    end

    def build_assets
      Dir[TableSetter.config_path + "/public/**/*"].each do |path|
        copy_file path, File.join(path.gsub(TableSetter.config_path + "/public/", "#{@out_dir}/"))
      end
    end

    def build_file(url, out)
      response = @request.get(url)
      if response.errors.length > 0
        puts "ERROR on #{url}:\n#{response.errors}" and exit 1
      end
      install_file(response.body, File.join(@out_dir, out))
    end

    def build_tables
      TableSetter::Table.all.each do |table|
        next if !table.live
        puts "Building #{table.slug}"
        build_file("#{@prefix}#{table.slug}/", File.join(table.slug, "index.html"))

        if table.hard_paginate?
          table.load
          (1..table.total_pages).each do |page|
            puts "Building #{table.slug} #{page} of #{table.total_pages}"
            build_file("#{@prefix}#{table.slug}/#{page}/",
                File.join(table.slug, page.to_s, "index.html"))
          end
        end
      end
    end

    def base_files
      Dir[ROOT + "/template/**/*"]
    end

    def copy_file(source, dest)
      ensure_directory dest
      exists = File.exists? dest
      FileUtils.cp_r(source, dest) unless exists
      puts "#{exists ? "exists" : "created"}\t#{dest}"
    end

    def ensure_directory(dest)
      expanded_path = File.dirname dest
      FileUtils.mkdir_p(expanded_path) unless File.exists?(expanded_path)
    end

    def install_file(body, dest)
      ensure_directory dest
      body.force_encoding("UTF-8") if RUBY_VERSION > "1.9"
      File.open(dest, "w") do |file|
        file.write(body)
      end
    end

  end
end
