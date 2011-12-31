class Uni_Mind
  module Appster
    
    def test_hello_world
    end
    
    def hello_world
      puts "Hi."
    end
    
    def test_print_info
      run
    end
    
    def test_uptime
      run
    end
     
    def uptime
      ssh.run("uptime")
    end
    
    def print_info prop
			puts "Server info: #{server.send(prop)}"
    end
    
  end # === module Appster
end # === Uni_Mind
