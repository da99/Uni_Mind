


class Uni_Mind

  class Template_Dir

    DIRS = [ :latest, :origins, :pending ]
    
    module Base
      
      include Checked::DSL::Racked

      attr_reader :hostname, :address
      
      def initialize raw_host
        @hostname = String!(raw_host).hostname!
        @address = File.join("configs/servers/#{hostname}/templates")
      end
     
      def addrs
        @dirs ||= DIRS.map { |str| File.join dot_slash, str }
      end
      
      def addr raw_name, file_name = :none
        Symbol!(raw_name).in! DIRS
        
        name = raw_name.to_s
        
        parts = [address, name]
        if file_name != :none
          parts << file_name
        end
        
        File.join *parts
      end

      def file addr
        Template_File.new(addr, self)
      end

      def files dir_name
        dir(dir_name).files.map { |file| 
          Template_File.new(file.address, self)
        }
      end
      
      def dir raw_name
        Unified_IO::Local::Dir.new(addr(raw_name))
      end
      
      include Unified_IO::Remote::SSH::DSL
      def upload
        # return files(:latest).each(&:upload)
        
        Dir.glob(File.join addr(:latest), '/*').each { |path|
          next unless File.file?(path)
          local = path
          remote = '/' + File.basename( path ).gsub(',', '/') 
          local_content = String!(File.read(local)).file_read!
          raw_remote = begin
                          ssh.run("[[ -f #{remote} ]] && cat #{remote}").strip
                        rescue Unified_IO::Remote::SSH::Failed  => e
                          ''
                        end
          remote_content = String!( raw_remote ).file_read!
          
          if !remote_content.empty? && local_content == remote_content # REMOTE EXISTS and is same?
            # do nothing
          elsif remote_content.empty?
            # upload
            puts "uploading file: #{local} => #{remote}"
            ssh.upload local, remote

          else
            # download to origins
            in_origins = Dir.glob(addr(:origins) + '/*').detect { |path|
              next unless File.file?(path)
              String!(File.read path).file_read! == remote_content
            }
            if in_origins
              # do nothing
            else
              orig_path = File.join(addr(:origins), path + Time.now.strftime(".%F--%T").gsub(':','.'))
              pend_path = File.join(addr(:pending), path + Time.now.strftime(".%F--%T").gsub(':','.'))
              File.open(orig_path, 'w' ) { |io| io.write remote_content }
              File.open(pend_path, 'w' ) { |io| io.write remote_content }
              shell.notify "Content needs to be reviewed/merged into :latest: #{pend_path}"
              abort
            end
          end
        }
      end

    end # === module Base

    include Base

  end # === module Template_Files

end # === class Uni_Mind
