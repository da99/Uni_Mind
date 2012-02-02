describe "Server :new" do
  
  it 'overwrites default values using servers/All.rb' do
    BIN("DB1/print_info/login").should.match %r!Server info: all_based_login!
  end
  
  it 'ignores a missing server/All.rb' do
    rmfile('servers/All.rb') {
      BIN("S1/print_info/login").should.match %r!Server info: appster_login!
    }
  end
  
  it 'overwrites default values using groups/NAME/server.rb' do
    BIN("S1/print_info/login").should.match %r!Server info: appster_login!
  end
  
  it 'ignores a missing groups/NAME/server.rb' do
    rmfile('groups/Appster/server.rb') {
      BIN("S1/print_info/login").should.match %r!Server info: all_based_login!
    }
  end
  
  it 'overwrites default values using server.rb' do
    BIN("LOCALHOST/print_info/login").should.match %r!Server info: #{`whoami`.strip}!
  end
  
  it 'sets hostname too downcased name of directory' do
    BIN("No_Hostname/print_info/hostname").should.match %r!Server info: no_hostname!
  end
  
end # === describe Server :new


