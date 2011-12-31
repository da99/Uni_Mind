


class Uni_Mind

  class Template_File

    Dirs = %w{ latest origins pending }
    
    module Base
      
      include Unified_IO::Local::Shell::DSL
      include Checked::Demand::DSL
      attr_reader :template_dir, :address, :remote
      
      def initialize raw_addr, tmpl_dir
        @template_dir = case tmpl_dir
                        when String
                          Template_Dir.new(tmpl_dir)
                        when Template_Dir
                          tmpl_dir
                        else
                          raise "Invalid class: #{tmpl_dir.inspect}"
                        end
        
        
        addr = demand!(raw_addr, :file_address!)
        
        @address = if File.file?(addr)
                     File
                       .basename(addr)
                       .sub( %r!\.[\d-\:]+$!, '' )
                       .gsub(',', '/')
                   else
                     addr
                   end

        @remote = Unified_IO::Remote::File.new( address  )
      end
      
      def local_basename
        address.gsub('/', ',')
      end

      def history_address
        ( local_basename + Time.now.strftime(".%F--%T").gsub(':','.') )
      end
      
      def latest_address
        File.join(template_dir.addr( :latest ), local_basename)
      end

      def latest
        @latest ||= Unified_IO::File_Twins.new( latest_address, address )
      end

      def in_dir? name
        Unified_IO::Local::Dir.new(template_dir.addr(name)).content?(remote.content)
      end

      def file_twins name
        local_addr = if remote.exists? && in_dir?(name)
                       Unified_IO::Local::Dir.new(template_dir.addr(name)).content_address(remote.content).address
                     else
                       template_dir.addr(name, history_address)
                     end
        
        Unified_IO::File_Twins.new( local_addr, address )
      end
      
      def upload
        #   
        #   Make sure far file has been:
        #     * downloaded before.
        #     * is not pending.
        # 
        download if remote.exists?
        latest.upload
      end # === def upload
      
      # 
      #  Must check to see if remote exists before using this method.
      #
      def download
        
        if in_dir?(:origins)
          shell.notify "Already downloaded to: #{template_dir.addr :origins}"
          return false
        end
        
        # notify "Downloaded [from] [to]:", address, pending.address
        file_twins(:origins).download
        file_twins(:pending).download 
        shell.notify "Content needs to be reviewed/merged into :latest: #{file_twins(:pending).local.address}"
        abort
        
      end # === def download
      
    end # === module Base

    include Base

  end # === module Template_Files

end # === class Uni_Mind
