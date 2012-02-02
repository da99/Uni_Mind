

describe "UNI_MIND */servers" do
  
  it 'sends message to all servers' do
    BIN(' */servers/print_info/hostname ')
    .scan(/Server info: (\w+)\n/).flatten.sort
    .should == HOSTNAMES
  end
  
end # === describe Server_Group.all


describe "UNI_MIND */groups" do
  
  it 'sends message to all groups' do
    target = ''
    chdir {
      target = Dir.glob("groups/*")
      .map { |path| 
        next unless File.directory?(path)
        "Group info: #{File.basename(path)}" 
      }
      .compact
      .join("\n")
    }
    
    BIN(' */groups/info/name ').should.match %r!#{Regexp.escape target}!i
  end
  
  it 'sends message to servers in group if it does not respond to message' do
    BIN(' */groups/print_info/hostname ')
    .scan(/Server info: (\w+)/).flatten.sort
    .should == HOSTNAMES
  end
  
end # === describe Server_Group.all

