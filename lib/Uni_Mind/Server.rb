
class Uni_Mind
  class Server
    module Base

      def print_info prop
        print "Server info: #{server.send prop }\n"
      end
      
      def server
        @server ||= begin
                      config = Hash[]
                      update = lambda { |file|
                        if File.exists?(file)
                          config.update eval(File.read(file), nil, file)
                        end
                      }
                      
                      update.call "servers/all.rb" 
                      update.call "servers/#{self.class.name}/server.rb"
                      update.call "groups/#{config[:group]}/server.rb"
                      
                      config[:hostname] ||= self.class.name.downcase
                      config[:custom] = [:group]
                      Unified_IO::Remote::Server.new(config, :custom=>[:group])
                    end
      end
      
    end # === module Base
  end # === class Server
end # === class Uni_Mind
