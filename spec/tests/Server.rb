describe "Server.config_file" do
  
  it 'raises error if multiple directories have the same downcased name'
  
end # === describe Server.config_file

describe "Server.server?" do
  
  it "returns true if server.rb file exists for server." do
    chdir {
      Uni_Mind::Server.server?('S1').should.be === true
    }
  end

  it "returns false if dir/file does not exist." do
    chdir {
      Uni_Mind::Server.server?('Krypton').should.be === false
    }
  end
  
end # === describe Server.server?

describe "Server.all" do
  
  it 'returns an array of Remote_Server objects' do
    chdir {
      all = Uni_Mind::Server.all
      all.map(&:hostname).sort.should == %w{ db1 s1 s2 }
    }
  end
  
end # === describe Server.all

describe "Server :new Hash[]" do
  
  it 'sets hostname too downcased name of directory' do
    chdir {
      Uni_Mind::Server.new("No_Hostname").hostname
      .should.be == 'no_hostname'
    }
  end
  
  it 'must require :group' do
    file = "servers/no_group.rb"
    content = "Hash[:hostname=>'err', :user=>'user']"
    mkfile(file, content) {
      lambda {
        Uni_Mind::Server.new(file)
      }.should.raise(Uni_Mind::Server::Missing_Property)
      .message.should.match %r!:group!i
    }
  end
  
  it 'uses defaults from group' do
    chdir {
      s =Uni_Mind::Server.new( "Group_Defaults" )
      s.login.should == 'appster_login'
      s.port.should  == 5000
    }
  end
  
  it 'uses defaults from All.rb' do
    chdir {
      s =Uni_Mind::Server.new( "All_Defaults" )
      s.login.should == 'all_based_login'
    }
  end

end # === describe Server

describe "Server.new file_path" do
  
  it 'sets hostname too downcased name of directory' do
    chdir {
      Uni_Mind::Server.new("servers/No_Hostname/server.rb").hostname
      .should.be == 'no_hostname'
    }
  end
  
  it 'uses defaults from group' do
    chdir {
      s = Uni_Mind::Server.new("servers/Appster_Defaults/server.rb")
      s.login.should.be == 'appster_login'
      s.port.should.be == 5000
    }
  end
  
end # === describe Server.new file_path
