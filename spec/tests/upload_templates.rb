
describe "Upload Templates" do
  
  behaves_like 'Uni_Mind'

  before {
    BOX.reset
  }

  it "uploads all templates to specified group" do
    glob("bdrm/upload.txt").should.be.empty
    BIN("bdrm upload_templates")
    glob("bdrm/upload.txt").should.not.be.empty
  end

  it 'aborts when there is pending file to review' do
    lambda {
      BIN_SKIP_IP_CHECK("ALL upload_templates")
    }.should.raise( Unified_IO::Local::Shell::Failed )
    .message.strip.split("\n")[-3].should.match %r!Content needs to be reviewed/merged into :latest!
  end

  it "uploads all templates to all servers" do
    glob("bdrm/upload.txt").should.be.empty
    glob("localhost/upload.txt").should.be.empty
    begin
      BIN_SKIP_IP_CHECK("ALL upload_templates")
    rescue Unified_IO::Local::Shell::Failed => e
    end
    glob("bdrm/upload.txt").should.not.be.empty
    glob("localhost/upload.txt").should.not.be.empty
  end
  
end # === describe Upload Templates
