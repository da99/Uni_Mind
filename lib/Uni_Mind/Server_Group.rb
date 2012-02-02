
class Uni_Mind

  class Server_Group

    module Base

      attr_reader :servers, :name

      def name 
        self.class.name
      end

      def info prop
        print "Group info: #{send prop}\n"
      end

      def servers
        @servers ||= begin
                      Dir.glob("servers/*").map { |path|
                        next unless File.directory?(path)
                        
                        klass_name = File.basename(path)
                        klass = Object.const_get klass_name
                        a = klass.new(klass_name, request.method_name, request.args)
                        next unless a.server.group == name
                        
                        klass
                      }.compact
                     end
      end
      
      def fulfill
        return super if respond_to?(request.method_name)
        
        invalid = []
        
        @apps ||= servers.map { |s| 
          a = Uni_Mind.new(s.name, request.method_name, *request.args) 
          if s.public_instance_methods.include?(request.method_name)
            a
          else
            invalid << a.request.path
            next
          end
        }

        if invalid.empty?
          response.body @apps.map(&:fulfill)
        else
          if invalid.size == servers.size
            raise Uni_Arch::Not_Found, request.path
          else
            raise Uni_Arch::Not_Found, invalid.join(', ')
          end
        end
      end

    end # === module Base

  end # === class Server
end # === class Uni_Mind
