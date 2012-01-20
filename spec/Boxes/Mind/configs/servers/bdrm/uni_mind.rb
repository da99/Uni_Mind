
class BDRM

  include Uni_Mind::Arch

  def print_info prop
    puts "Server info: #{env.server.send prop }"
  end
    
end # === class BDRM


