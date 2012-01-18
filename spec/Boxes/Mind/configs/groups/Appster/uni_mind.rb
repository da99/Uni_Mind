
class Appster

  include Uni_Mind::Arch
  include Unified_IO::Local::Shell::DSL

  Map = '/Appster'

  def hello name
    puts "Hiya, #{name}"
  end

  def uptime
    ssh.run("uptime")
  end

  def print_info prop
    servers.each { |s|
      puts "Server info: #{s.send(prop)}"
    }
  end
  
  private # ====================
  
end # === class Appster


Uni_Mind.use Appster
  
