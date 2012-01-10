
class BDRM

  include Uni_Arch::Base
  include Uni_Mind::Base

  namespace '/bdrm'

  route '/print_info/!w prop!/'
  def print_info 
    puts "Server info: #{server.send(request.captures[:prop])}"
  end
    
  
end # === class BDRM


Uni_Mind.use BDRM
  
