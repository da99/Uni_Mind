

class Uni_Mind
  class Template_Dir

    include Unified_IO::Remote::SSH::DSL
    include Unified_IO::Local::Shell::DSL

    DIRS = [ :latest, :origins, :pending ]

    attr_reader :hostname, :address

    def initialize app
      server app.server
      @address  = File.join("servers/#{app.class}/templates")
    end

    def addr raw_name, file_name = :none
      raise ArgumentError, "Unknown dir: #{raw_name.inspect}" unless DIRS.include?(raw_name)

      parts = [address, raw_name.to_s]
      if file_name != :none
        parts << file_name
      end

      File.join *parts
    end

    def sync
      Dir.glob(File.join addr(:latest), '/*').each { |latest|
        next unless File.file?(latest)

        basename       = File.basename( latest )
        
        remote         = basename.gsub(',', '/') 
        remote_content = begin
                           r = Unified_IO::Remote::File.new(remote, server)
                           r.content
                         rescue Unified_IO::Remote::File::Not_Found
                           ''
                         end
        
        local_content  = Unified_IO::Local::File.new(latest).content
        the_same       = !remote_content.empty? && local_content == remote_content

        if  the_same
          # do nothing
          # 
        elsif remote_content.empty?

          # upload
          shell.tell "uploading file: #{latest} => #{remote}"
          scp_upload latest, remote

        else

          # download to origins
          in_origins = Dir.glob(addr(:origins) + '/*').detect { |path|
            next unless File.file?(path)
            Unified_IO::Local::File.new(path).content == remote_content
          }

          if in_origins
            # do nothing
          else
            new_file = nil
            [:origins, :pending].each { |folder|
              new_file = File.join(addr(folder), basename + Time.now.strftime(".%F--%T").gsub(':','.'))
              File.open(new_file, 'w' ) { |io| io.write remote_content }
            }
            shell.tell "Content needs to be reviewed/merged into :latest: #{new_file}"
            abort
          end
        end
      }
    end

  end # === module Template_Files
end # === class Uni_Mind
