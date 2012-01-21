
class ALL

  include Uni_Mind::Arch

  def servers *args
    Unified_IO::Remote::Server.all.each { |s|
      Uni_Mind.new(s.hostname, *args).fulfill
    }
  end

  def groups *args
    Unified_IO::Remote::Server_Group.all.each { |g|
      Uni_Mind.new(g.name, *args).fulfill
    }
  end
  
end # === class ALL
