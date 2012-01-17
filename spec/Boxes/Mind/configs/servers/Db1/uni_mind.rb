
class Db1 < Sinatra::Base

  include Uni_Mind::Arch

  map '/Db1'

  get '/print_info/:prop'
  def print_info 
    puts "Server info: #{server.send(params[:prop])}"
  end
    
  
end # === class Db1


Uni_Mind.use Db1
  
