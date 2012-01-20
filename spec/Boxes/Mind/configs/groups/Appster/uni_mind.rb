
class Appster

  include Uni_Mind::Arch

  def hello name
    puts "Hiya, #{name}"
  end

  def uptime
    ssh.run("uptime")
  end
  
end # === class Appster


