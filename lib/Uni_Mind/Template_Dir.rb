


class Uni_Mind

  class Template_Dir

    DIRS = [ :latest, :origins, :pending ]
    
    module Base
      
      include Checked::Demand::DSL

      attr_reader :hostname, :address
      
      def initialize raw_host
        @hostname = demand!(raw_host, :hostname!)
        @address = File.join("configs/servers/#{hostname}/templates")
      end
     
      def addrs
        @dirs ||= DIRS.map { |str| File.join dot_slash, str }
      end
      
      def addr raw_name, file_name = :none
        d = Checked::Demand.new(DIRS) 
        d.include! raw_name
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
      
      def upload
        files(:latest).each(&:upload)
      end

    end # === module Base

    include Base

  end # === module Template_Files

end # === class Uni_Mind
