
class Uni_Mind
  class Recipes
    class ALL 
      include Uni_Mind::Arch
      
			Map = "/ALL"

      def groups *args
        Unified_IO::Remote::Server_Group.all.each { |group|
          app = Uni_Mind.new(File.join '/', group.name, *args)
					app.fulfill_request
        }
      end

      def servers *args
        Unified_IO::Remote::Server.all.each { |server|
          app = Uni_Mind.new(File.join '/', server.hostname, *args)
					app.fulfill_request
        }
      end

    end # === class ALL
  end # === class Recipes
end # === class Uni_Mind
