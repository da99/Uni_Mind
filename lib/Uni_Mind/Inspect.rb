
class Uni_Mind
  module Inspect

    module Group
    end # === module Group

    module Server

      def print_info prop
        print "Server info: #{env.server.send prop }\n"
      end
      
    end # === module Server
    
  end # === module Inspect
  
end # === class Uni_Mind
