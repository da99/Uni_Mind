class Uni_Mind
  module Appster
    
    def test_hello_world
    end
    
    def hello_world
      puts "Hi."
    end
    
    def test_create_file
      run
    end
    
    def test_uptime
      run
    end
     
    def uptime
      ssh.run("uptime")
    end
    
    def create_file file_name
      path = "/tmp/Uni_Mind/#{server.hostname}/#{args.first}"
      dir = File.dirname(path)
      `mkdir -p #{dir}` unless Dir.exists?(dir)
      
      File.open(path, 'w') { |io|
        io.write "Created for #{server.group}"
      }
    end
    
  end # === module Appster
end # === Uni_Mind
