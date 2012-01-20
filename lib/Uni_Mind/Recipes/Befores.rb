
class Uni_Mind
  module Set_Servers
    def set_group_or_servers
      name = path.split('/')[1]
      name = '*' if name == 'ALL'
      return unless name

      case path
      when %r!/ALL/servers!
        env_create 'servers', Unified_IO::Remote::Server.all
      when %r!/ALL/groups!
        env_create 'groups',  Unified_IO::Remote::Server_Group.all
      else

        if Unified_IO::Remote::Server.group?(name)
          env_create 'group', Unified_IO::Remote::Server_Group.new(name)
          env_create 'servers', env.group.servers
        elsif Unified_IO::Remote::Server.server?(name)
          env_create 'server',  Unified_IO::Remote::Server.new( name )
        end

      end
    end
  end
end # === class Uni_Mind

class Uni_Mind
  class Recipes
    class Befores 

      include Uni_Mind::Arch
      
      Map = "/*"

      def request! *args
        grab_uni_arch_files
        set_group_or_servers
      end

      def grab_uni_arch_files
        %w{ groups servers }.each { |cat|
          (Dir.glob("configs/#{cat}/*/Uni_Arch.rb") + Dir.glob("configs/#{cat}/*/uni_arch.rb")).each { |file|
            require File.expand_path(file)
          }
        }
      end

      def set_group_or_servers
        name = path.split('/')[1]
        name = '*' if name == 'ALL'
        return unless name

        case path
        when %r!/ALL/servers!
          env_create 'servers', Unified_IO::Remote::Server.all
        when %r!/ALL/groups!
          env_create 'groups',  Unified_IO::Remote::Server_Group.all
        else

          if Unified_IO::Remote::Server.group?(name)
            env_create 'group', Unified_IO::Remote::Server_Group.new(name)
            env_create 'servers', env.group.servers
          elsif Unified_IO::Remote::Server.server?(name)
            env_create 'server',  Unified_IO::Remote::Server.new( name )
          end

        end
      end

    end # === class Befores
  end # === class Recipes

end # === class Uni_Mind
