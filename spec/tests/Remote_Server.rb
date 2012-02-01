describe "Server.config_file" do
  
  it 'raises error if multiple directories have the same downcased name'
  
end # === describe Server.config_file

describe "Server.server?" do
  
  it "returns true if dir/file exists for server." do
    Dir.chdir("spec/Boxes") {
      Unified_IO::Remote::Server.server?('s1').should.be === true
    }
  end

  it "returns false if dir/file does not exist." do
    Dir.chdir("spec/Boxes") {
      Unified_IO::Remote::Server.server?('Krypton').should.be === false
    }
  end
  
end # === describe Server.server?

describe "Server.all" do
  
  it 'returns an array of Remote_Server objects' do
    Dir.chdir('spec/Boxes') {
      all = Unified_IO::Remote::Server.all
      all.map(&:hostname).sort.should == %w{ db1 s1 s2 }
    }
  end
  
end # === describe Server.all

describe "Server :new Hash[]" do
  
  it 'must require :group' do
    lambda {
      Unified_IO::Remote::Server.new(
        :hostname=>'localhost', 
        :user=>'user'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Group!i
  end
  
  it 'must require :hostname' do
    lambda {
      Unified_IO::Remote::Server.new(
        :group=>'Local', 
        :user=>'user'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Hostname!i
  end

  it 'must raise Invalid_Property for mis-spelled property' do
    lambda {
      Unified_IO::Remote::Server.new(
        :group=> 'Local',
        :user=>'user',
        :hostname=>'app',
        :nickname=>'CONAN'
      )
    }.should.raise(Unified_IO::Remote::Server::Invalid_Property)
    .message.should.match %r!Nickname!i
  end
  
  it 'uses defaults from group' do
    chdir {
      s =Unified_IO::Remote::Server.new( :group=>'Appster', :hostname=>'none' )
      s.login.should == 'appster_login'
      s.port.should  == 5000
    }
  end
  
  it 'uses defaults from All.rb' do
    chdir {
      s =Unified_IO::Remote::Server.new( :group=>'Db1', :hostname=>'none' )
      s.login.should == 'all_based_login'
    }
  end

end # === describe Server

describe "Server.new file_path" do
  
  it 'sets hostname too downcased name of directory' do
    chdir {
      Unified_IO::Remote::Server.new("servers/No_Hostname/server.rb").hostname
      .should.be == 'no_hostname'
    }
  end

  it 'raises Duplicates error if multiple directories have the same downcased name' do
    name = "NO_HOSTname"
    mkdir("servers/#{name}") {
      lambda {
        Unified_IO::Remote::Server.new("servers/#{name}/server.rb")
      }.should.raise(Unified_IO::Remote::Server::Duplicates)
      .message.should.match %r!#{name}!
    }
  end
  
  it 'uses defaults from group' do
    chdir {
      s = Unified_IO::Remote::Server.new("servers/Appster_Defaults/server.rb")
      s.login.should.be == 'appster_login'
      s.port.should.be == 5000
    }
  end
  
end # === describe Server.new file_path
