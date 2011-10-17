
class Uni_Mind
  
  module ArchLinux

    def install_packages *raw_names
      names = raw_names.flatten.join(' ')
      cmd = "pacman -S #{names}"
      sudo(cmd)
    end

    def install_from_source name
      installed = !( ssh( "which #{name}" ).strip.empty? )
      if not installed

        return( yield ) if block_given?

        sudo "apt-get install #{name}"

      end
    end

  
  end # === module

end # === class
