
describe "Upload Templates" do
	
	behaves_like 'Uni_Mind'

	after {
		Dir.glob("/tmp/Uni_Mind/*/*.txt").each { |file|
			File.delete file
		}
	}
	
	it "uploads all templates to specified group" do
		@bin.call("Appster upload_templates")
		Dir.glob("/tmp/Uni_Mind/App1/*.txt").should.not.be.empty
		Dir.glob("/tmp/Uni_Mind/App2/*.txt").should.not.be.empty
		Dir.glob("/tmp/Uni_Mind/Db1/*.txt").should.be.empty
	end

	it "uploads all templates to all groups" do
		@bin.call("ALL upload_templates")
		Dir.glob("/tmp/Uni_Mind/Db1/*.txt").should.not.be.empty
	end
	
end # === describe Upload Templates
