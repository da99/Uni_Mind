
class Appster < Sinatra::Base

  include Uni_Mind::Arch

  map '/Appster'

  get '/hello/:name/'
  def hello_world
    puts "Hiya, #{params[:name]}"
  end

  get
  def uptime
    ssh.run("uptime")
  end

  get '/print_info/:prop/'
  def print_info 
    servers.each { |s|
      puts "Server info: #{s.send(params[:prop])}"
    }
  end
  
  private # ====================
  
end # === class Appster


Uni_Mind.use Appster
  
