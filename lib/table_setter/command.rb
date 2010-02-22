require 'optparse'


module TableSetter
  class Command
    BANNER = <<-EOB
table-setter is a Sinatra application for rendering and processing CSVs from google docs into HTML.

Usage:
  table-setter COMMAND path/to/table-setter/assets
  
commands:
  start    run the development server, for deployment use config.ru
  install  copy the table-setter assets into the the directory
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
      puts "Starting TableSetter"
      TableSetter::App.run!
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
