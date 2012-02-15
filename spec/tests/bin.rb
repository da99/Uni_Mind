
describe "permissions of bin/" do
  
  it "should be 770" do
    `stat -c %a bin`.strip
    .should.be == "770"
  end
  
end # === permissions of bin/

