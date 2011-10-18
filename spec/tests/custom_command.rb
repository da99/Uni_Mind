
describe "Custom command" do
  
  behaves_like 'Uni_Mind'
  
  after {
    glob("*/to_appster.rb").each { |file|
      File.delete file
    }
  }

  it "sends custom command to specified group" do
    BIN("Appster create_file to_appster.rb")
    exists?("isle1/to_appster.rb").should.be == true
    exists?("isle2/to_appster.rb").should.be == true
    exists?("db1/to_appster.rb").should.be == false
  end
  
  it "sends custom command to all servers" do
    BIN("ALL create_file to_all.rb")
    exists?("isle1/to_all.rb").should.be == true
    exists?("isle2/to_all.rb").should.be == true
    exists?("db1/to_all.rb").should.be == true
  end
  
end # === describe Custom command
