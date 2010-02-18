module TableSetter
  class Table < TableFu
    attr_reader :key
    
    def last_modified
      open("http://spreadsheets.google.com/feeds/list/#{@key}/od6/public/basic").last_modified
    end
    
    
    class << self
      def load(yaml)
        new do |t|
          
        end
      end
    end
  end
end