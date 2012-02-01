
class Uni_Mind
  class All
    
    module Class_Methods
      
      def groups
        Dir.glob("groups/*").map { |path|
          next unless File.directory?(path)
          Object.const_get(File.basename(path))
        }.compact
      end
      
      def group? name
        File.directory?("groups/")
      end
      
    end # === module Class_Methods
    
    Duplicates = Class.new(RuntimeError)
    Not_Found  = Class.new(RuntimeError)

    extend Class_Methods
    include Uni_Mind::Arch

    def servers *args
      Unified_IO::Remote::Server.all.each { |s|
        Uni_Mind.new(s.hostname, *args).fulfill
      }
    end

    def groups *args
      self.class.groups.each { |g|
        Uni_Mind.new(g.name, *args).fulfill
      }
    end

  end # === class ALL
end # === class Uni_Mind
