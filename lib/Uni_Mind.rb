require "Uni_Mind/version"
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'

class Uni_Arch

  module Class_Methods
    
    def middleware
      @middleware ||= []
    end

    def use val
      middleware << val
      middleware.uniq!
      val
    end
    
  end # === module Class_Methods
  
  
  module Arch
    
    attr_accessor :path, :env
    attr_reader   :methods
    
    def self.included klass
      klass.extend ::Uni_Arch::Class_Methods unless klass.is_a?(Module)
    end

    def initialize path, env = {}
      @path    = path
      @env     = env
      @methods = []
    end

    def fulfill_request
      raise Frozen, path if frozen?

      pieces = path.split('/')
      ns     = pieces[0,2].join('/')
      meth   = pieces[2, 1].first
      args   = pieces[3, pieces.size - 3]

      klasses = self.class.middleware.select { |klass|
        klass.const_defined?(:Map) && [ns, '/*'].include?(klass::Map)
      }

      if klasses.empty?
        raise ArgumentError, "No middleware found for: #{path}, using namespace: #{ns}, in: #{Uni_Mind.middleware.inspect}"
      end

      result = nil
      environ = {}
      klasses.each { |k|
        app = k.new(path, environ)
        begin
          result = app.request! meth, *args
          methods << [ k, :request! ]
        rescue NoMethodError => e
          raise e unless e.message['undefined method `request!']
          begin
            result = app.public_send meth, *args
            methods << [ k, meth ]
          rescue ArgumentError => e
            raise e unless e.message["wrong number of arguments"] && e.backtrace.first["`#{meth}'"]
          rescue NoMethodError => e
            raise e unless e.message["undefined method `#{meth}'"]
          end
        end
      }

      raise Not_Found, path if methods.empty?

      freeze
      result
    end

    Retry_Command = Class.new(RuntimeError)
    def ssh_run *args
      env.servers
      begin
        super
      rescue Timeout::Error => e
        raise e.class, env.server.inspect
      rescue Net::SSH::HostKeyMismatch => e
        if e.message[%r!fingerprint .+ does not match for!]
          shell "ssh-keygen -f \"#{File.expand_path "~/.ssh/known_hosts"}\" -R #{env.server[:ip]}"
          raise Retry_Command, "Removed the RSA key."
        end
      end
    end

  end # === module Arch

end # === class Uni_Arch

class Uni_Mind

  Wrong_IP         = Class.new(RuntimeError)
  Server_Not_Found = Class.new(RuntimeError)
  Retry_Command    = Class.new(RuntimeError)
  Not_Found        = Class.new(RuntimeError)
  Frozen           = Class.new(RuntimeError)

  module Arch
    
    def self.included klass
      klass.extend ::Uni_Arch::Class_Methods
    end

    include Uni_Arch::Arch
    include Unified_IO::Local::Shell::DSL
    include Unified_IO::Remote::SSH::DSL
    include Checked::DSL::Racked

  end # === module Arch
  
  include Arch
  
end # === class Uni_Mind

%w{ 
  Befores 
  ALL 
  Templates
}.each { |name|
  require "Uni_Mind/Recipes/#{name}"
  Uni_Mind.use Uni_Mind::Recipes.const_get(name.to_sym)
}



Dir.glob("configs/**/uni_mind.rb").each { |file|
  require File.expand_path( file.sub('.rb', '') )
}
