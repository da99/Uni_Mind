

class Uni_Mind
  class Template_Dir

    include Unified_IO::Remote::SSH::DSL
    include Unified_IO::Local::Shell::DSL

    DIRS = [ :latest, :origins, :pending ]

    attr_reader :hostname, :address

    def initialize server
      self.server = server
      @address  = File.join("configs/servers/#{server.hostname}/templates")
    end

    def addr raw_name, file_name = :none
      raise ArgumentError, "Unknown dir: #{raw_name.inspect}" unless DIRS.include?(raw_name)

      parts = [address, raw_name.to_s]
      if file_name != :none
        parts << file_name
      end

      File.join *parts
    end

    def read_file path
      content = begin
                  File.read(path)
                rescue Errno::ENOENT
                  begin
                    # ssh.exits(0,1).run("[[ -f #{path} ]] && cat #{path}").strip
                    ssh_run("[[ -f #{path} ]] && cat #{path}").strip
                  rescue Unified_IO::Remote::SSH::Failed
                      ''
                  end
                end

      content.gsub("\r", '').strip
    end

    def sync

      Dir.glob(File.join addr(:latest), '/*').each { |latest|
        next unless File.file?(latest)

        basename       = File.basename( latest )
        remote         = basename.gsub(',', '/') 
        remote_content = read_file(remote)
        local_content  = read_file(latest)
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
            read_file(path) == remote_content
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
