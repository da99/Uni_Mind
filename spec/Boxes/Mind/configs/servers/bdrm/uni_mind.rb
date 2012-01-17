
class BDRM < Sinatra::Base

  include Uni_Mind::Arch

  map '/bdrm'

  get '/print_info/:prop/'
  def print_info 
    puts "Server info: #{server.send(params[:prop])}"
  end
    
  
end # === class BDRM


Uni_Mind.use BDRM
  