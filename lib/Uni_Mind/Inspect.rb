
class Uni_Mind
	module Inspect
		
    def print_info prop
      puts "Server info: #{env.server.send prop }"
    end
		
	end # === module Inspect
	
end # === class Uni_Mind
