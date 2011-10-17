


class Uni_Mind

  class Template_File

    Dirs = %w{ latest origin pending }
    
    module Base
      
      include Checked::Demand::DSL
      attr_reader :template_dir, :address, :far
      
      def initialize raw_addr, tmpl_dir
        @template_dir = case tmpl_dir
                    when String
                      Template_Dir.new(tmpl_dir)
                    when Template_Dir
                      tmpl_dir
                    else
                      raise "Invalid class: #{tmpl_dir.inspect}"
                    end
        
        
        addr = demand(raw_addr, :file_address!)
        
        @address = if File.file?(addr)
                     File
                       .basename(demand(addr, :file_not!))
                       .sub( %r!\.[\d-\:]+$!, '' )
                       .gsub(',', '/')
                   else
                     addr
                   end

        @far = Far_File.new( address  )
      end
      
      def local_basename
        address.gsub('/', ',')
      end

      def history_address
        ( local_basename + Time.now.strftime(".%F--%T") )
      end
      
      def latest_address
        File.join(template_dir.addr( :latest ), local_basename)
      end

      def latest
        @latest ||= File_Twins.new( latest_address, address )
      end

      def in_dir? name
        Local_Dir.new(template_dir.addr(name)).content?(name)
      end

      def file_twins name
        local_addr = if in_dir?(name)
                       Local_Dir.new(template_dir.addr(name)).content_address(far.content)
                     else
                       template_dir.addr(name, history_address)
                     end
        
        File_Twins.new( local_addr, address )
      end
      
      def upload
        #   
        #   Make sure far file has been:
        #     * downloaded before.
        #     * is not pending.
        # 
        download
        latest.upload
      end # === def upload
      
      # 
      #   if content not in pending:
      #     Download target file.
      #     Yell at user of new content.
      #     
      #   Content is now pending:
      #     Yell at user.
      #     Abort.
      #
      def download
        
        if in_dir?(:origin)
          shell.notify "Already downloaded to: #{template_dir.addr :origin}"
          return false
        end
        
        # notify "Downloaded [from] [to]:", address, pending.address
        file_twins(:origin).download
        file_twins(:pending).download 
        shell.notify "Content needs to be reviewed/merged into :latest: #{file_twins(:pending).local.address}"
        abort
        
      end # === def download
      
    end # === module Base

    include Base

  end # === module Template_Files

end # === class Uni_Mind
