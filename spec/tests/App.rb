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
  it 'requires each server to have a unique hostname'
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

describe "UNI_MIND cache gems" do
  
  it 'creates /bin in each dir in /apps'
  it 'sets each sheband to ruby-local-exec'
  it 'packages the gems for each app'
  
end # === describe UNI_MIND deploy_bundles

describe "UNI_MIND create sinatra app" do
  
  it 'does not overwrite existing files.'
  it 'creates folder /name'
  it 'creates folder /name/config'
  it 'creates folder /name/public'
  it 'creates file   /name/config.ru'
  it 'creates file   /name/name.rb'
  it 'creates file   /name/Gemfile'
  it 'creates file   /name/bin'
  it 'changes the ruby executable in bin files to ruby-local-exec'
  
end # === describe UNI_MIND sin_app

describe "UNI_MIND deploy" do
  
  it 'demands each app has no pending commits'
  it 'demands file: apps.rb'
  it 'creates user and group name:name for each app'
  it "copies app files to /apps/name/date"
  
  it 'sets permissions on /apps/name/date/* to name:name 740'
  it "moves, not copies, app's public dir to /public/name/date"
  
  it "sets permissions on /public/name/date/* to name:name 744"
  
  it "creates link /apps/name/current => /apps/date/name"
  it "creates link /public/name/current => /public/date/name"
  
  it "does not create link if app is already up-to-date"
  it "restarts nginx"
  
end # === describe UNI_MIND deploy
