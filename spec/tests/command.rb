class Aok

  include Uni_Mind::Arch

  def aok?
    "aok"
  end
  
end # === class Test_It < Sinatra::Base


describe "BIN args" do
  
  it "loads a file with the same name as the directory" do
    target = 
    BIN("/Appster/hello/Uni_Mind/").split("\n").last
    .should.be == "Hiya, Uni_Mind"
  end
  
end # === BIN args

describe "Uni_Mind.new(path).fulfill" do
  
  after {
    glob("*/to_appster.rb").each { |file|
      File.delete file
    }
  }
  
  it 'executes command that returns result' do
    Uni_Mind.new("/aok/aok?").fulfill
    .should.be == 'aok'
  end
  
end # === describe Custom command

