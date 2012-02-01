
describe "Server_Group.new" do
  
  it 'grabs all servers within that group' do
    chdir {
      group = Uni_Mind::Server_Group.new("Appster")
      group.servers.map(&:hostname).sort.should == %w{ s1 s2 }
    }
  end
  
end # === describe Server_Group

describe "Server_Group.all" do
  
  it 'grabs all servers for group "*"' do
    ruby_e(%~
      puts( 
        Uni_Mind::Server_Group.all
        .map(&:to_s).sort.inspect
      )
    ~).should == %w{ Appster Bermuda Db }.inspect
  end
  
end # === describe Server_Group.all

describe "Server_Group.group?" do
  
  it "returns true if dir/file exists for group." do
    chdir {
      Uni_Mind::Server_Group.group?('Appster').should.be === true
    }
  end

  it "returns false if dir/file does not exist." do
    chdir {
      Uni_Mind::Server_Group.group?('DATA').should.be === false
    }
  end
  
end # === describe Server_Group.group?

