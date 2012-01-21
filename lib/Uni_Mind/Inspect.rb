
class Uni_Mind
  module Inspect

    module Group

      def print_info prop
        env.servers.each { |serv| 
          puts "Server info: #{serv.send prop }"
        }
      end

    end # === module Group

    module Server

      def print_info prop
        puts "Server info: #{env.server.send prop }"
      end
      
    end # === module Server
    
  end # === module Inspect
  
end # === class Uni_Mind
