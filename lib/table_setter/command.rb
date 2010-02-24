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

options:
    EOB
    
    
    def initialize
      parse_options
      command = ARGV.shift
      @directory = ARGV.shift || '.'    
      case command
      when 'start' then start_server
      when 'install' then install_assets
      end
    end
    
    def start_server
      TableSetter.configure @directory
      require 'rack'
      require 'rack/showexceptions'
      require 'rack/commonlogger'
      require 'rack/lint'
      app = Rack::Builder.new {
        use Rack::CommonLogger, STDERR
        use Rack::ShowExceptions
        use Rack::Lint
        run TableSetter::App
      }.to_app
      Rack::Handler::Thin.run app, :Port => "3000"
    end
    
    def install_assets
      FileUtils.mkdir_p @directory unless File.exists? @directory
      TableSetter.configure @directory
      puts "\nInstalling TableSetter files...\n\n"
      base_files.each do |path|
        create_file path, TableSetter.config_path + path.gsub(ROOT + "/template/", "/") 
      end
    end
    
    private
    # Option parsing
    def parse_options
      @options = {}
      @option_parser = OptionParser.new do |opts|

      end
      @option_parser.banner = BANNER
      @option_parser.parse! ARGV
    end
    
    def base_files
      Dir[ROOT + "/template/**/*"]
    end
    
    def create_file(source, dest)
      exists = File.exists? dest
      FileUtils.cp_r(source, dest) unless exists
      puts "#{exists ? "exists" : "created"}\t#{dest}"
    end
    
  end
end  
