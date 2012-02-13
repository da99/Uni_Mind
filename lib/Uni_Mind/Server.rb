
class Uni_Mind
  module Server
    
    Duplicate = Class.new(RuntimeError)

    module Arch

      def print_info prop
        print "Server info: #{server.send prop }\n"
      end
      
      def server
        @server ||= begin
                      last = Hash[]
                      config = Hash[]
                      update = lambda { |target, file|
                        if File.exists?(file)
                          target.update eval(File.read(file), nil, file)
                        end
                      }
                      
                      update.call last, "servers/#{self.class.name}/server.rb"
                      update.call config, "servers/All.rb" 
                      update.call config, "groups/#{last[:group]}/server.rb"
                      config.update last
                      
                      config[:hostname] ||= self.class.name.downcase
                      config[:custom] = [:group]
                      Unified_IO::Remote::Server.new(config, :custom=>[:group])
                    end
      end
      
    end # === module Arch
  end # === module Server
end # === class Uni_Mind
