


class Uni_Mind

  class Template_Dir

    DIRS = [ :latest, :origins, :pending ]
    
    module Base
      
      include Checked::DSL::Ruby

      attr_reader :hostname, :address
      
      def initialize raw_host
        @hostname = not_empty!(raw_host.strip)
        @address = File.join("configs/servers/#{hostname}/templates")
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
                      ssh.exits(0,1).run("[[ -f #{path} ]] && cat #{path}").strip
                    rescue Unified_IO::Remote::SSH::Failed
                      ''
                    end
                  end
        
        content.gsub("\r", '').strip
      end

      def ssh
        @ssh ||= Unified_IO::Remote::SSH.new 
      end

      def sync
        # return files(:latest).each(&:upload)
        
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
            puts "uploading file: #{latest} => #{remote}"
            ssh.upload latest, remote

          else
            
            # download to origins
            in_origins = Dir.glob(addr(:origins) + '/*').detect { |path|
              next unless File.file?(path)
              read_file(path) == remote_content
            }
            
            if in_origins
              # do nothing
            else
              orig_path = File.join(addr(:origins), basename + Time.now.strftime(".%F--%T").gsub(':','.'))
              pend_path = File.join(addr(:pending), basename + Time.now.strftime(".%F--%T").gsub(':','.'))
              File.open(orig_path, 'w' ) { |io| io.write remote_content }
              File.open(pend_path, 'w' ) { |io| io.write remote_content }
              puts "Content needs to be reviewed/merged into :latest: #{pend_path}"
              abort
            end
          end
        }
      end

    end # === module Base

    include Base

  end # === module Template_Files

end # === class Uni_Mind
