
describe "Apps :new" do
  
  after { `rm #{@err} ` if File.exists?(@err) }
  
  before { 
    extend Unified_IO::Local::Shell::DSL

    @apps = begin
              e = Dir.entries("#{FOLDER}/Mind/apps").sort
              e.shift
              e.shift
              e
            end
  
    @name = @apps.last
    @err  = "#{FOLDER}/Mind/apps/#{@name}/config/thin.err.yml"
  }
  
  it 'creates an array of apps from ./apps/*/config directory' do
    chdir { 
      Uni_Mind::Apps.new.to_a.map(&:name).sort.should == @apps 
    }
  end
  
  it 'raises Invalid_Chdir if chdir is not /apps/app_name' do
    chdir {
      shell_run "thin config -C #{@err} --chdir /wrong/dir/#{@name} -u #{@name} -g #{@name} -e production"
      lambda { Uni_Mind::Apps.new }
      .should.raise(Uni_Mind::App::Invalid_Chdir)
      .message.should.match %r!/wrong/dir/#{@name}!
    }
  end

  it 'raises Duplicate_Port if the same port overlaps with another' do
    target = "#{[1002].inspect} in #{["apps/bye_02/config/thin.one.yml", "apps/hi_01/config/thin.err.yml"].inspect}"
    chdir {
      shell_run "thin config -C #{@err} --chdir /apps/#{@name} -p 1002 -u #{@name} -g #{@name} -e production"
      lambda { Uni_Mind::Apps.new }
      .should.raise(Uni_Mind::App::Duplicate_Port)
      .message.should.match %r!#{Regexp.escape target}!
    }
  end
  
  it 'raises Invalid_Port if port is less than 1000' do
    chdir {
      shell_run "thin config -C #{@err} --chdir /apps/#{@name} -p 102 -u #{@name} -g #{@name} -e production"
      lambda { Uni_Mind::Apps.new }
      .should.raise(Uni_Mind::App::Invalid_Port)
      .message.should.match %r!102!
    }
  end
  
  it 'raises Invalid_User if user is not the same as app name' do
    chdir {
      shell_run "thin config -C #{@err} --chdir /apps/#{@name} -p 1000 -u #{@name}s -g #{@name} -e production"
      lambda { Uni_Mind::Apps.new }
      .should.raise(Uni_Mind::App::Invalid_User)
      .message.should.match %r!#{@name}s!
    }
  end
  
  it 'raises Invalid_Group if group is not the same as app name' do
    chdir {
      shell_run "thin config -C #{@err} --chdir /apps/#{@name} -p 1000 -u #{@name} -g #{@name}g -e production"
      lambda { Uni_Mind::Apps.new }
      .should.raise(Uni_Mind::App::Invalid_Group)
      .message.should.match %r!#{@name}g!
    }
  end

  it 'raises Invalid_Env if environment is not production' do
    chdir {
      shell_run "thin config -C #{@err} --chdir /apps/#{@name} -p 1000 -u #{@name} -g #{@name} "
      lambda { Uni_Mind::Apps.new }
      .should.raise(Uni_Mind::App::Invalid_Env)
      .message.should.match %r!development!
    }
  end

  it 'raises Invalid_Server_Count if :servers is zero' do
    chdir {
      shell_run "thin config -C #{@err} --chdir /apps/#{@name} -p 1000 -u #{@name} -g #{@name} --servers 0 "
      lambda { Uni_Mind::Apps.new }
      .should.raise(Uni_Mind::App::Invalid_Server_Count)
      .message.should.match %r!0!
    }
  end
  
end # === describe Apps :new

describe "Apps :to_a" do
  
  it 'returns an array of Uni_Mind::App objects' do
    chdir {
      Uni_Mind::Apps.new.to_a.each { |a|
        a.should.be.is_a Uni_Mind::App
      }
    } 
  end
  
end # === describe Apps :to_a


describe "Apps :to_mustache" do
  
  it 'returns an array of hashes to be used in mustache templates' do
    chdir {
      target = Uni_Mind::Apps.new.to_a.map { |app|
        [app.name, app.ports]
      }.flatten
      Uni_Mind::Apps.new.to_mustache.each { |m|
        m['ports'].size.should.not.be.zero
        target.should.include m['name']
      }
    } 
  end
  
end # === describe Apps :to_mustache
