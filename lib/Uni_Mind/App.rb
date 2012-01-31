
class Uni_Mind
  class App
    
    module Class_Methods
      
      def thin_config name, port, file_name = nil
        file_name ||= name
        file_path = "apps/#{name}/config/thin.#{file_name}.yml"
        
        raise Config_Already_Exists, file_path if File.exists?(file_path)
        
        cmd = %~
          bundle exec
          thin config 
            -C #{File.expand_path file_path}
            -p #{Integer port} 
            -c /apps/#{name} 
            -e production 
            -u #{name} 
            -g #{name} 
            --servers #{2} 
        ~.split.join(' ')
        
        Unified_IO::Local::Shell.new.run(cmd)
        
        new(file_path)
      end
      
    end # === module Class_Methods
    
    extend Class_Methods
    
    Invalid_Chdir  = Class.new(RuntimeError)
    Duplicate_Port = Class.new(RuntimeError)
    Config_Already_Exists = Class.new(RuntimeError)
    Invalid_Port   = Class.new(RuntimeError)
    Invalid_User   = Class.new(RuntimeError)
    Invalid_Group  = Class.new(RuntimeError)
    Invalid_Env    = Class.new(RuntimeError)
    Invalid_Server_Count = Class.new(RuntimeError)
    
    Mustache_Props = [:name, :chdir, :ports, :environment, :file_name]
    attr_reader *Mustache_Props

    def initialize file_name
      y = file_name
      @name = y[%r!/([^/]+)/config/!] && $1
      @file_name = file_name
      
      h = YAML.load(File.read File.expand_path(y))
      
      port = h['port'].to_i
      raise Invalid_Port, h.inspect if port < 1000
      
      servers = (h['servers'] || 1).to_i
      raise Invalid_Server_Count, h.inspect if servers < 1
      
      if name != h['user']
        raise Invalid_User, h['user'].inspect + " should be #{name}"
      end
      
      if name != h['group']
        raise Invalid_Group, h['group'].inspect + " should be #{name}"
      end
       
      if h['environment'] != 'production'
        raise Invalid_Env, h.inspect
      end
      
      if h['chdir'] != "/apps/#{name}"
        raise Invalid_Chdir, h['chdir']
      end

      @ports = (0...servers).map do |i|
        port + i
      end
      
      @chdir = h['chdir']
    end
    
    def to_mustache
      Mustache_Props.inject({}) { |m, prop|
        m[prop.to_s] = send(prop)
        m
      }
    end

  end # === class App
end # === class Uni_Mind
