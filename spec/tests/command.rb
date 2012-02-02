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
  
end # === describe Custom command
