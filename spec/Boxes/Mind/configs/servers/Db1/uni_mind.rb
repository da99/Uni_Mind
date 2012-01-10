
class Db1

  include Uni_Arch::Base
  include Uni_Mind::Base

  namespace '/Db1'

  route '/print_info/!w prop!/'
  def print_info 
    puts "Server info: #{server.send(request.captures[:prop])}"
  end
    
  
end # === class Db1


Uni_Mind.use Db1
  
