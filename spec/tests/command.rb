class Aok

  include Uni_Mind::Arch

  def aok?
    "aok"
  end
  
end # === class Test_It < Sinatra::Base


describe "Custom command" do
  
  after {
    glob("*/to_appster.rb").each { |file|
      File.delete file
    }
  }
  
  it 'executes command that returns result' do
    app = Uni_Mind.new("/aok/aok?")
    app.fulfill.should.be == 'aok'
  end
  
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
  
  it "raises Uni_Arch::Not_Found if command is sent to Group that Server does not execute" do
    m = lambda { BIN("Appster hello_db") }
    .should.raise(Unified_IO::Local::Shell::Failed)
    .message
    
    m.should.match %r!::Not_Found!
    m.should.match %r!/?Appster/hello_db, /?Appster/hello_db!
  end
  
end # === describe Custom command
