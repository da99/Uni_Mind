
class Uni_Mind
  class Recipes
    class Befores < Sinatra::Base

      include Uni_Mind::Arch

      before
      def grab_uni_arch_files
        %w{ groups servers }.each { |cat|
          Dir.glob("configs/#{cat}/*/uni_arch.rb").each { |file|
            require File.expand_path(file)
          }
        }
      end

      before
      def set_group_or_servers
        name = request.path.split('/')[1]
        name = '*' if name == 'ALL'
        return unless name

        case request.path
        when %r!/ALL/servers!
          request.env['servers'] = Unified_IO::Remote::Server.all
        when %r!/ALL/groups!
          request.env['groups'] = Unified_IO::Remote::Server_Group.all
        else

          if Unified_IO::Remote::Server.group?(name)
            request.env['group'] = Unified_IO::Remote::Server_Group.new(name)
            request.env['servers'] = group.servers
          end

          if Unified_IO::Remote::Server.server?(name)
            request.env['server'] = Unified_IO::Remote::Server.new( name )
          end

        end
      end


    end # === class Befores
  end # === class Recipes

end # === class Uni_Mind
