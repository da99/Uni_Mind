
# 
# Modules for adding server group functionality
# to a class.
#
class Uni_Mind
  module Group
    module Arch

      attr_reader :name

      def request!
        r = super
        request.method_name!
        r
      end

      def name 
        self.class.name
      end

      def info prop
        print "Group info: #{send prop}\n"
      end

      def server_klasss
        @server_klasss ||= servers.map(&:class)
      end

      def servers
        @servers ||= begin
                       ips       = {}
                       hostnames = {}
                      
                       Dir.glob("servers/*").map { |path|
                         next unless File.directory?(path)

                         # Grab the klass of the server.
                         klass = Object.const_get File.basename(path)
                         a     = klass.new(klass, request.method_name, *request.args)
                         next unless a.server.group == name

                         # Duplicate ip?
                         ip = a.server.ip
                         if ips.has_key?(ip)
                           raise Uni_Mind::Server::Duplicate, "IP: #{ip} in #{ips[ip]}, #{klass}"
                         end
                         ips[ip] = klass

                         # Duplicate hostname?
                         hn = a.server.hostname
                         if hostnames.has_key?(hn)
                           raise Uni_Mind::Server::Duplicate, "Hostname: #{hn} in #{hostnames[hn]}, #{klass}"
                         end
                         hostnames[hn] = klass

                         # Add to list.
                         a
                       }.compact
                     end
      end
      
      def fulfill
        return super if respond_to?(request.method_name)
        
        invalid = []
        
        @apps ||= servers.map { |s| 
          if s.respond_to?(request.method_name)
            s
          else
            invalid << s.request.path
            next
          end
        }

        if invalid.empty?
          response.body @apps.map(&:fulfill)
        else
          if invalid.size == servers.size
            raise Uni_Arch::Not_Found, "#{request.path} for all #{name} servers"
          else
            raise Uni_Arch::Not_Found, "#{invalid.join(', ')} (#{name} group)"
          end
        end
      end # === fulfill

    end # === module Arch
  end # === module Group
end # === class Uni_Mind
