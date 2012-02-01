
class Uni_Mind
  class Server
    module Base

      def print_info prop
        print "Server info: #{env.server.send prop }\n"
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
                      
                      config[:custom] = [:group]
                      Unified_IO::Remote::Server.new(config)
                    end
      end
      
    end # === module Base
  end # === class Server
end # === class Uni_Mind
