
describe "Custom command" do
  
  behaves_like 'Uni_Mind'
  
  after {
    glob("*/to_appster.rb").each { |file|
      File.delete file
    }
  }

  it 'executes command' do
    target = "Hiya, Uni_Mind"
    BIN("/Appster/hello/Uni_Mind/").split("\n").last.should.be == target
  end

  it "sends custom command to specified group" do
    target = "Server info: bdrm\nServer info: localhost"
    BIN("/Appster/print_info/hostname/").should.match %r!#{Regexp.escape target}!
  end
  
  it "sends custom command to all servers" do
    target = "Server info: bdrm\nServer info: localhost\nServer info: Db1"
    BIN("ALL servers print_info hostname").should.match %r!#{Regexp.escape target}!
  end
  
end # === describe Custom command
