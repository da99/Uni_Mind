


class Uni_Mind

  class Template_Dir

    DIRS = [ :latest, :origin, :pending ]
    
    module Base
      
      include Checked::Demand::DSL

      attr_reader :hostname, :address
      
      def initialize raw_host
        @hostname = demand(raw_host, :hostname!)
        @address = File.join('templates', hostname)
      end
     
      def addrs
        @dirs ||= DIRS.map { |str| File.join dot_slash, str }
      end
      
      def addr raw_name, file_name = :none
        name = demand(raw_name) { |v|
          v.in! DIRS
        }
        
        if file_name == :none
          File.join address
        else
          File.join address, file_name
        end
      end

      def file addr
        Template_File.new(addr, self)
      end

      def files dir_name
        dir(dir_name).files.map { |file| 
          Template_File.new(file.address)
        }
      end
      
      def dir raw_name
        Local_Dir.new(addr(raw_name))
      end
      
      def upload
        files(:latest).each(&:upload)
      end

    end # === module Base

    include Base

  end # === module Template_Files

end # === class Uni_Mind
