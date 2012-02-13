
describe "Upload Templates" do
  
  before {
    BOX.reset
  }

  it "uploads all templates to specified server" do
    chdir {
      Dir.glob("../bdrm/upload.txt").should.be.empty
      
      BIN("localhost upload_templates")
      
      Dir.glob("../bdrm/upload.txt").should.not.be.empty
    }
  end

  it 'aborts when there is pending file to review' do
    lambda {
      BIN_SKIP_IP_CHECK("*/servers/upload_templates")
    }.should.raise( Unified_IO::Local::Shell::Failed )
    .message.should.match %r!Content needs to be reviewed/merged into :latest!
  end
  
end # === describe Upload Templates
