
class Appster

  include Uni_Arch::Base

  namespace '/Appster'

  route '/hello/!w name!/'
  def hello_world
    puts "Hiya, #{request.captures[:name]}"
  end

  route
  def uptime
    ssh.run("uptime")
  end

  route '/print_info/!w prop!/'
  def print_info 
    request.env.servers.each { |s|
      puts "Server info: #{s.send(request.captures[:prop])}"
    }
  end
  
  private # ====================

  def server
    request.env.server
  end
    
  
end # === class Appster


Uni_Mind.use Appster
  
