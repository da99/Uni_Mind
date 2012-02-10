
describe "UNI_MIND Group/action/arg" do

  it "sends custom command to specified group" do
    target = "Server info: s2\nServer info: appster_defaults"
    BIN("/Appster/print_info/hostname/").should.match %r!#{Regexp.escape target}!
  end
  
  it "raises 'Uni_Arch::Not_Found, path' if none of the servers fulfills request" do
    m = lambda { BIN("Appster hello_db") }
    .should.raise(Unified_IO::Local::Shell::Failed)
    .message
    
    m.should.match %r!: /?Appster/hello_db for all Appster servers \(Uni_Arch::Not_Found\)!
  end
  
  it "raises 'Uni_Arch::Not_Found, path' if at least one of the servers does not fulfill" do
    m = lambda { BIN("Appster s1_info") }
    .should.raise(Unified_IO::Local::Shell::Failed)
    .message
    
    m.should.not.match %r!S1/s1_info!i 
    m.should.match %r!S2/s1_info!
  end
  
end # === describe UNI_MIND Group/action/arg
