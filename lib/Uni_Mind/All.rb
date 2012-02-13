
class Uni_Mind

  module Arch

    def initialize *raw
      # Load classes for server groups and servers.
      groups
      servers
      
      super(*raw)
    end

    def request!
      if [:*, '*'].include?(request.klass)
        request.method_name! "all_#{request.method_name}"
        request.klass! self.class
      end
      
      super
    end

    def thin_config *args
      Uni_Mind::App.thin_config *args
    end

    def require_classes type
      Dir.glob("#{type}/*").map { |path|
        name = File.basename(path).sub('.rb','').to_sym
        next unless File.directory?(path)
        require "./#{type}/#{name}/#{name}"
        
        Object.const_get(name)
      }.compact
    end

    def servers *args
      @servers ||= require_classes(:servers) 
    end

    def groups *args
      @groups ||= require_classes(:groups)
    end

    def all *args
      send "all_#{args.shift}", *args
    end

    def all_servers *args
      servers.each { |s|
        Uni_Mind.new(File.join s.name, *args).fulfill
      }
    end

    def all_groups *args
      groups.each { |g|
        Uni_Mind.new(File.join g.name, *args).fulfill
      }
    end

  end # === module Uni_Mind
  
end # === class Uni_Mind
