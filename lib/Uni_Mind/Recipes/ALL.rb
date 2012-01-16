
class Uni_Mind
  class Recipes
    class ALL < Sinatra::Base
      include Sin_Arch::Arch
      
      get "/ALL/groups/*"
      def to_all_groups
        Unified_IO::Remote::Server_Group.all.each { |group|
          app = Uni_Mind::App.new
          app.get!("/#{group.name}/#{params[:splat].join('/')}")
        }
        
        'ok'
      end

      get "/ALL/servers/*"
      def to_all_servers
        Unified_IO::Remote::Server.all.each { |server|
          app = Uni_Mind::App.new
          app.get!("/#{server.hostname}/#{params[:splat].join('/')}")
        }
        
        'ok'
      end

    end # === class ALL
  end # === class Recipes
end # === class Uni_Mind
