class Aok

  include Uni_Mind::Arch

  def aok?
    "aok"
  end
  
end # === class Test_It < Sinatra::Base

    
describe "Startup:" do
  
  it 'executes command that returns result' do
    app = Uni_Mind.new("/aok/aok?")
    app.fulfill.should.be == 'aok'
  end
  
end # === describe Sending a command to a server:
