class Test_It < Sinatra::Base

  include Sin_Arch::Arch

  get "/aok" do
    return! "aok"
  end
  
end # === class Test_It < Sinatra::Base

Uni_Mind.use Test_It
    
describe "Startup:" do
  
  it 'executes command' do
    Uni_Mind::App.new.get!("/aok").should.be == 'aok'
  end
  
end # === describe Sending a command to a server:
