APPS = "/tmp/Uni_Mind_Apps"

`rm -r #{APPS}` if File.directory?(APPS)
`mkdir -p #{APPS}/apps/a1/config`
`mkdir -p #{APPS}/apps/b2/config`
`mkdir -p #{APPS}/apps/c3/config`
`cp spec/Boxes/Mind/Gemfile #{APPS}/../Gemfile`
`cp Gemfile.lock #{APPS}/../Gemfile.lock`

def thin_config *args
  file = nil
  Dir.chdir(APPS) {
    file = Uni_Mind::App.thin_config *args
  }
  
  file
end

def thin_read name, file = nil
  YAML.load File.read(File.join APPS, 'apps', name, "config/thin.#{file || name}.yml")
end

describe "require Uni_Mind" do

  after { BOX.reset }
  
  it 'requires each server to have a unique hostname' do
    chdir {
      
      file         ="servers/No_Hostname/server.rb"
      h            = eval(File.read(file))
      h[:hostname] = `hostname`.strip
      h[:ip] = "0.0.0.0"
      
      File.open(file, 'w') do |io|
        io.write h.inspect
      end
      
      lambda { BIN("Appster/print_info/hostname") }
      .should.raise(Unified_IO::Local::Shell::Failed)
      .message.should.match %r!Hostname: #{`hostname`.strip} in \w+, No_Hostname!
      
    }
  end
  
  it 'requires each server to have a unique ip' do
    chdir {
      
      file         ="servers/No_Hostname/server.rb"
      h            = eval(File.read(file))
      h[:hostname] = `hostname`.strip
      
      File.open(file, 'w') do |io|
        io.write h.inspect
      end
      
      lambda { BIN("Appster/print_info/hostname") }
      .should.raise(Unified_IO::Local::Shell::Failed)
      .message.should.match %r!IP: #{`hostname`.strip} in \w+, No_Hostname!
      
    }
  end
  
end

describe "App :thin_config" do
  
  it 'returns a Uni_Mind::App' do
    Dir.chdir(APPS) {
      Uni_Mind::App.thin_config( "a1", 1000 )
      .should.be.is_a Uni_Mind::App
    }
  end
  
  it 'raises App::Config_Already_Exists if config file exists.' do
    lambda { 
      thin_config 'a1', 1009 
      thin_config 'a1', 1030 
    }
    .should.raise(Uni_Mind::App::Config_Already_Exists)
    .message.should.match %r!a1!
  end

  it 'generates a .yml file starting with thin.' do
    thin_config("b2", 1010)
    thin_read('b2').should.be.is_a Hash
  end

  it 'sets user to name of app' do
    thin_read('b2')['user'].should == 'b2'
  end

  it 'sets group to name of app' do
    thin_read('a1')['group'].should == 'a1'
  end

  it 'sets servers to 2' do
    thin_read('a1')['servers'].should == 2
  end

  it 'allows a custom file name: thin.custom.yml' do
    thin_config 'c3', 1050, 'uno'
    thin_read('c3', 'uno').should.is_a Hash
  end

  it 'sets chdir to /apps/name' do
    thin_read('c3', 'uno')['chdir'].should == '/apps/c3'
  end

  it 'sets environment to production' do
    thin_read('c3', 'uno')['environment'].should == 'production'
  end
  
end # === describe App :thin_config

describe "UNI_MIND thin_config" do
  
  it 'generates thin file' do
    name = "bye_#{rand 1000}"
    BOX.mkdir "Mind/apps/#{name}/config" do |f|
      BIN("thin_config #{name} 4567 uni")
      File.exists?(File.join f, "thin.uni.yml").should == true
    end
  end
  
end # === describe UNI_MIND thin_config name port file_name

describe "UNI_MIND sinatra create_app" do
  
  before {
    chdir {
      `rm -rf Hi_App`
    }
  }
  
  it 'does not overwrite existing files.' do
    target = %!Original #{rand(10)}!
    chdir {
      `mkdir -p Hi_App`
      File.open('Hi_App/app.rb', 'w') do |io|
        io.write target
      end
      
      BIN "sinatra/create_app Hi_App"

      File.read("Hi_App/app.rb").should == target
    }
  end

  it 'creates folder /name/public' do
    BIN "sinatra/create_app Hi_App"
    chdir {
      File.directory?("Hi_App/public")
      .should.be == true
    }
  end

  it 'creates file   /name/config.ru' do
    str = "run Hi_App"
    BIN "sinatra/create_app Hi_App"
    chdir {
      File.read("Hi_App/config.ru")[str]
      .should == str
    }
  end

  it 'creates file   /name/name.rb' do
    str = "class Hi_App"
    BIN "sinatra/create_app Hi_App"
    chdir {
      File.read("Hi_App/Hi_App.rb")[str]
      .should == str
    }
  end

  it 'creates file   /name/Gemfile' do
    r = %r!gem .sinatra.!
    BIN "sinatra/create_app Hi_App"
    chdir {
      File.read("Hi_App/Gemfile")[r]
      .should.match r
    }
  end

  it 'git ignores tmp/*' do
    BIN "sinatra/create_app Hi_App"
    chdir {
      File.read("Hi_App/.gitignore")[%r!^tmp/\*$!]
      .should == "tmp/*"
    }
  end
  
  it 'git ignores logs/*' do
    BIN "sinatra/create_app Hi_App"
    chdir {
      File.read("Hi_App/.gitignore")[%r!^logs/\*$!]
      .should == "logs/*"
    }
  end

  it 'creates a git commit of: First commit' do
    BIN "sinatra/create_app Hi_App"
    chdir {
      `cd Hi_App && git log -n 1 --oneline`.strip
      .should.match %r!First commit!
    }
  end

end # === describe UNI_MIND sinatra create_app

describe "UNI_MIND deploy" do
  
  
  it 'demands each app has no pending commits' do

  end
  
  it 'raises Missing_File if missing: apps.rb' do

  end
  
  it 'creates /bin in each app' do

  end
  
  it 'sets each sheband to ruby-local-exec' do

  end
  
  it 'creates /vendor for each app' do

  end
  
  it 'creates user and group name:name for each app' do

  end
  
  it "copies app files to /apps/name/source" do

  end
  
  it 'sets permissions on /apps/name/source/* to name:name 740' do

  end
  
  it 'copies, not moves, /public file to /app/name/public' do

  end
  
  it "sets permissions on /app/name/public to name:name 744" do

  end
  
  it "restarts nginx if apps are being deployed for the first time" do

  end
  
  it "touches /app/name/tmp/restart.txt in each app" do
    
  end
  
end # === describe UNI_MIND deploy

describe "UNI_MIND revert NAME N" do
  
  it 'reverts app to previous data/time tag' do

  end

end # === UNI_MIND revert NAME N

describe "UNI_MIND deploy NAME" do
  
  it "deploys reverted app to latest date/time tag" do
    
  end
  
end # === UNI_MIND deploy NAME

