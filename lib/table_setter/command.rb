require 'optparse'


module TableSetter
  class Command
    BANNER = <<-EOB
table-setter is a Sinatra application for rendering and processing CSVs from google docs into HTML.

Usage:
  table-setter COMMAND path/to/table-setter/assets OPTIONS
  
commands:
  start    run the development server, for deployment use config.ru
  install  copy the table-setter assets into the the directory
  export   statically build tables in the ./out/
  
options:
    EOB
    
    
    def initialize
      @prefix = ""
      parse_options
      command = ARGV.shift
      @directory = ARGV.shift || '.'
      case command
      when 'start' then start_server
      when 'install' then install_assets
      when 'build' then build_out
      end
    end
    
    def start_server
      TableSetter.configure @directory
      require 'rack'
      require 'rack/showexceptions'
      require 'rack/commonlogger'
      require 'rack/lint'
      prefix = @prefix
      app = Rack::Builder.app do
        map "/#{prefix}" do
          use Rack::CommonLogger, STDERR
          use Rack::ShowExceptions
          use Rack::Lint
          run TableSetter::App
        end
      end
      Rack::Handler::Thin.run app, :Port => "3000"
    end
    
    def install_assets
      FileUtils.mkdir_p @directory unless File.exists? @directory
      TableSetter.configure @directory
      puts "\nInstalling TableSetter files...\n\n"
      base_files.each do |path|
        copy_file path, File.join(TableSetter.config_path, path.gsub(ROOT + "/template/", "/"))
      end
    end
    
    
    def build_out
      require 'rack'      
      TableSetter.configure @directory
      out_dir = File.join(TableSetter.config_path, 'out', @prefix)
      puts "\nBuilding your TableSetter files...\n\n"
      prefix = @prefix
      app = Rack::Builder.app do
        map "/#{prefix}" do
          run TableSetter::App
        end
      end
      
      request = Rack::MockRequest.new(app)
      install_file(request.request("GET", "/#{@prefix}/").body,
                      File.join(out_dir, "index.html"))
      Dir[ROOT + "/template/public/**/*"].each do |path|
        copy_file path, File.join(path.gsub(ROOT + "/template/public/", "#{out_dir}/"))
      end
      
      TableSetter::Table.all.each do |table|
        puts "Building #{table.slug}"
        install_file(request.request("GET", "/#{@prefix}/#{table.slug}/").body,
                    File.join(out_dir, table.slug, "index.html"))
        if table.hard_paginate?
          table.load
          (1..table.total_pages).each do |page|
            puts "Building #{table.slug} #{page} of #{table.total_pages}"
            install_file(request.request("GET", "/#{@prefix}/#{table.slug}/#{page}/").body,
                File.join(out_dir, table.slug, page.to_s, "index.html"))
          end
        end
      end
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
    
    def base_files
      Dir[ROOT + "/template/**/*"]
    end
    
    def copy_file(source, dest)
      FileUtils.mkdir_p(File.dirname dest) unless File.exists?(File.dirname dest)
      exists = File.exists? dest
      FileUtils.cp_r(source, dest) unless exists
      puts "#{exists ? "exists" : "created"}\t#{dest}"
    end
    
    def install_file(body, dest)
      FileUtils.mkdir_p(File.dirname dest) unless File.exists?(File.dirname dest)
      File.open(dest, "w") do |f|
        f.write(body)
      end
    end
    
  end
end  
