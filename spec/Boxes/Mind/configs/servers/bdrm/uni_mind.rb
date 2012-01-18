
class BDRM

  include Uni_Mind::Arch
  include Unified_IO::Local::Shell::DSL

  Map = '/bdrm'

  def print_info prop
    puts "Server info: #{server.send prop }"
  end
    
end # === class BDRM


Uni_Mind.use BDRM
  
