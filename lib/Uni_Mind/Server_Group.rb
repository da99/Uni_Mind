
class Uni_Mind

  class Server_Group

    module Base

      attr_reader :servers, :name

      def name 
        self.class.name
      end

      def servers
        @servers ||= begin
                      Dir.glob("servers/*").map { |path|
                        next unless File.directory?(path)
                        
                        klass_name = File.dirname(path)
                        s = Uni_Mind::Server.new(klass_name)
                        next unless s.group == name
                        
                        Object.const_get klass_name
                      }.compact
                     end
      end

    end # === module Base

  end # === class Server
end # === class Uni_Mind
