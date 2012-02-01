
module Unified_IO
  module Remote

		module Base_Class_Methods

			include Checked::DSL
			
			def config_file type, name
				if name == '*'
					return ::Dir.glob("#{type}s/*/#{type}.rb")
				end

				File_Path!( name ) unless name == '*'
				default_file = "#{type}s/#{name}/#{type}.rb"
				return default_file if ::File.exists?(default_file)

				target = default_file.downcase
				files = meta_config_file(type, '*').select { |file| file.downcase == target } 

				raise Duplicates, files.inspect if files.size > 1
				files.first || default_file
			end

			def all
				config_file( '*' ).map { |file|
					new( file )
				}
			end

		end # === module Base_Class_Methods

    class Server_Group
      
      Not_Found  = Class.new(RuntimeError)
      Duplicates = Class.new(RuntimeError)

      module Class_Methods
        
				include Base_Class_Methods
			
				def config_file name
					super :group, name
				end

        def group? name
          c = config_file( name )
					::File.file?(c) ||
						::File.directory?( ::File.dirname c )
        end

      end # === module Class_Methods
      
      extend Class_Methods
      
      module Base
        
        attr_reader :servers, :name

        def initialize raw_name
          @name = raw_name
          @servers = config_file( '*' ).map { |file|

            hostname = begin
                         pieces = file.split('/')
                         pieces.pop
                         pieces.pop
                       end
            
            server = Unified_IO::Remote::Server.new( hostname )
          
            if server.group.to_s == name.to_s
              server
            else
              nil
            end
              
          }.compact

          raise Server_Group::Not_Found, name if servers.empty?
        end

      end # === module Base
      
      include Base

    end # === class Server
  end # === module Remote
end # === module Unified_IO
