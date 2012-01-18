
class Db1 

  include Uni_Mind::Arch
  include Unified_IO::Local::Shell::DSL

  Map = '/Db1'

  def print_info prop
    puts "Server info: #{server.send prop}"
  end
    
  
end # === class Db1


Uni_Mind.use Db1
  
