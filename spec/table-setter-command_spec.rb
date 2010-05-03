require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


INSTALL_DIRECTORY = File.join("/", "tmp", "table-setter-test", "/")

def cleanup
  if File.exists? INSTALL_DIRECTORY
    FileUtils.rm_r INSTALL_DIRECTORY
  end
end

def install
  `#{File.join(File.dirname(__FILE__), "..", "table-setter")} install #{INSTALL_DIRECTORY}`
end


describe TableSetter::Command do
  
  after(:each) do 
    cleanup
  end
  
  before(:each) do
    install
  end
  
  it 'should install the configuration directory in a custom spot' do
    template_dir = File.join(File.dirname(__FILE__), "..", "template")
    
    Dir["#{template_dir}/**/*"].each do |template_file|
      File.exists?(template_file.gsub(template_dir, INSTALL_DIRECTORY)).should be_true
    end
  end
end