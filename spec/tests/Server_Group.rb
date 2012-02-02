

describe "UNI_MIND */servers" do
  
  it 'sends message to all servers' do
    target = ''
    chdir {
      target = Dir.glob("servers/*")
      .map { |path| 
        next unless File.directory?(path)
        "Server info: #{File.basename(path)}" 
      }
      .compact
      .join("\n")
    }
    
    BIN(' */servers/print_info/hostname ').should.match %r!#{Regexp.escape target}!i
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
    targets = ''
    chdir {
      targets = Dir.glob("servers/*")
      .map { |path| 
        next unless File.directory?(path)
        "Server info: #{File.basename(path)}" 
      }
      .compact
    }
    
    results = BIN(' */groups/print_info/hostname ')
    targets.each { |t|
      results.should.match %r!#{Regexp.escape t}!i
    }
  end
  
end # === describe Server_Group.all

