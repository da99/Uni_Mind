
describe "Sending a command to a server:" do
  
  it "raises Uni_Mind::Wrong_IP when hostnames do not match" do
    lambda {
      BIN("localhost uptime")
    }.should.raise(Unified_IO::Local::Shell::Failed)
    .message.strip.split("\n")[1].should
    .match %r!#{Regexp.escape %!(Uni_Mind::Wrong_IP)!}\Z!
  end
  
  
end # === describe Sending a command to a server:
