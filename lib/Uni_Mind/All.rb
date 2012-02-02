
class Uni_Mind
  class All
    
    module Class_Methods
      
      def all type
        Dir.glob("#{type}/*").map { |path|
          next unless File.directory?(path)
          Object.const_get(File.basename(path))
        }.compact
      end
      
      def groups
        all :groups
      end

      def servers
        all(:servers)
      end
      
    end # === module Class_Methods
    
    extend Class_Methods
    
    Duplicates = Class.new(RuntimeError)
    Not_Found  = Class.new(RuntimeError)

    include Uni_Mind::Arch

    def servers *args
      self.class.servers.each { |s|
        Uni_Mind.new(s.name, *args).fulfill
      }
    end

    def groups *args
      self.class.groups.each { |g|
        Uni_Mind.new(g.name, *args).fulfill
      }
    end

  end # === class ALL
end # === class Uni_Mind
