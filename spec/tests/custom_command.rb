
describe "Custom command" do
  
  behaves_like 'Uni_Mind'
  
  after {
    glob("*/to_appster.rb").each { |file|
      File.delete file
    }
  }

  it "sends custom command to specified group" do
    target = "Server info: bdrm\nServer info: localhost"
    BIN("Appster print_info hostname").should.be == target
  end
  
  it "sends custom command to all servers" do
    target = "Server info: bdrm\nServer info: localhost\nServer info: Db1"
    BIN("ALL print_info hostname").should.be == target
  end
  
end # === describe Custom command
