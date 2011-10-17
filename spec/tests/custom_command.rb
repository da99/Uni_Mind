
describe "Custom command" do
	
	behaves_like 'Uni_Mind'
	
	after {
		Dir.glob("/tmp/Uni_Mind/*/to_appster.rb").each { |file|
			File.delete file
		}
	}

	it "sends custom command to specified group" do
		@bin.call("Appster create_file to_appster.rb")
		File.exists?("/tmp/Uni_Mind/App1/to_appster.rb").should.be == true
		File.exists?("/tmp/Uni_Mind/App2/to_appster.rb").should.be == true
		File.exists?("/tmp/Uni_Mind/Db1/to_appster.rb").should.be == false
	end
	
	it "sends custom command to all servers" do
		@bin.call("ALL create_file to_all.rb")
		File.exists?("/tmp/Uni_Mind/App1/to_appster.rb").should.be == true
		File.exists?("/tmp/Uni_Mind/App2/to_appster.rb").should.be == true
		File.exists?("/tmp/Uni_Mind/Db1/to_appster.rb").should.be == true
	end
	
end # === describe Custom command
