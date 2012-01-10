
class LOCALHOST

  include Uni_Arch::Base
  include Uni_Mind::Base

  namespace '/localhost'

  route '/print_info/!w prop!/'
  def print_info 
    puts "Server info: #{server.send(request.captures[:prop])}"
  end
  
end # === class LOCALHOST


Uni_Mind.use LOCALHOST
  
