
class Uni_Mind
  
  module Server
    MODS.each { |m|
      include Uni_Mind.const_get(m.to_sym)::Server
    }
  end # === module Server
  
end # === class Uni_Mind



class Unified_IO
  
  module Remote

    class Server
      
      module Class_Methods

        include Base_Class_Methods

        def config_file name
          super :server, name
        end

        def server? name
          pattern = "/#{name.downcase}/"
          
          !! config_file('*').detect { |file|
            file.downcase[ pattern ]
          }
        end

      end # === module Class_Methods

      Not_Found  = Class.new(RuntimeError)
      Duplicates = Class.new(RuntimeError)
      Invalid_Property = Class.new(RuntimeError)

      PROPS = [
        :ip, :port, :hostname, 
        :group,
        :user, :default, 
        :login, :root, :password
      ]

      extend Class_Methods
      attr_reader :origin, *PROPS
      attr_accessor :os_name

      def initialize file_or_hash, opts = {}
        hash = case file_or_hash

               when Hash
                 file_or_hash

               when String

                 if ::File.file?(file_or_hash)
                   server = eval(::File.read file_or_hash )
                   server[:hostname] ||= (file_or_hash[%r!servers/([^/]+)/server.rb!] && $1).downcase
                   server
                  
                 else
                   server = eval( ::File.read( self.class.config_file file_or_hash ) )
                   server[:hostname] ||= file_or_hash.downcase
                  
                   if opts[:root]
                     server[:root] = true
                   end

                   server
                 end
                
               else
                 raise "Unknown data type: #{file_or_hash.inspect}"
                
               end

        invalid = hash.keys - PROPS
        raise Invalid_Property, "Invalid keys: #{invalid.inspect}" unless invalid.empty?

        if hash.has_key?(:password) && hash[:password].strip.empty?
          raise Invalid_Property, ":password can't be set as empty string."
        end

        if hash[:root]
          hash[:login] = 'root'
          hash.delete :root
        end

        if ENV['PASSWORD']
          hash[:password] = ENV['PASSWORD']
          hash[:login] = 'root'
        end

        @origin = hash
        origin.keys.each { |key|
          instance_variable_set :"@#{key}", origin[key]
        }

        @port ||= '22'
        if !group
          raise Invalid_Property, "Group must be set for server #{hostname}."
        end
        @group = group.to_s.strip

        if !hostname.is_a?(String)
          raise Invalid_Property, "Invalid hostname: #{hostname.inspect}"
        end

        @ip    ||= @hostname
        @user  ||= @login
        @login ||= @user

      end # === def initialize

    end # === class Server
  end # === module Remote

end # === module Unified_IO
