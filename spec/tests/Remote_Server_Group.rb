
describe "Server_Group.new" do
  
  it 'grabs all servers within that group' do
    chdir {
      group = Unified_IO::Remote::Server_Group.new("Appster")
      group.servers.map(&:hostname).sort.should == %w{ s1 s2 }
    }
  end
  
end # === describe Server_Group

describe "Server_Group.all" do
  
  it 'grabs all servers for group "*"' do
    chdir {
      group = Unified_IO::Remote::Server_Group.all
      group.map(&:name).sort.should == %w{ Appster Db }
    }
  end

  it 'raises Server_Group::Not_Found if no servers are found' do
    lambda { Unified_IO::Remote::Server_Group.all }
    .should.raise(Unified_IO::Remote::Server_Group::Not_Found)
    .message.should.match %r!None!i
  end
  
end # === describe Server_Group.all

describe "Server_Group.group?" do
  
  it "returns true if dir/file exists for group." do
    chdir {
      Unified_IO::Remote::Server_Group.group?('Appster').should.be === true
    }
  end

  it "returns false if dir/file does not exist." do
    chdir {
      Unified_IO::Remote::Server_Group.group?('DATA').should.be === false
    }
  end
  
end # === describe Server_Group.group?

