class Aok

  include Uni_Mind::Arch

  Map = '/aok'

  def aok?
    "aok"
  end
  
end # === class Test_It < Sinatra::Base

Uni_Mind.use Aok
    
describe "Startup:" do
  
  it 'executes command that returns result' do
    app = Uni_Mind.new("/aok/aok?")
    app.fulfill_request.should.be == 'aok'
  end
  
end # === describe Sending a command to a server:
