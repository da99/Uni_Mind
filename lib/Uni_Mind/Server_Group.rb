
class Uni_Mind

  class Server_Group

    module Base

      attr_reader :servers, :name

      def initialize raw_name
        raise Server_Group::Not_Found, name unless File.directory?("groups/#{raw_name}")
        
        @name = raw_name
        @servers = config_file( '*' ).map { |file|

          server = ::Uni_Mind::Server.new( file )

          if server.group == name
            server
          else
            nil
          end

        }.compact

      end

    end # === module Base

  end # === class Server
end # === class Uni_Mind
