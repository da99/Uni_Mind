
class LOCALHOST

  include Uni_Mind::Arch
  include Unified_IO::Local::Shell::DSL

  Map = '/localhost'

  def print_info prop
    puts "Server info: #{env.server.send prop}"
  end
  
end # === class LOCALHOST


Uni_Mind.use LOCALHOST
  
