require "Uni_Mind/version"
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'


class Uni_Mind
  
  Wrong_IP         = Class.new(RuntimeError)
  Server_Not_Found = Class.new(RuntimeError)
  Retry_Command    = Class.new(RuntimeError)
  Not_Found        = Class.new(RuntimeError)

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

    include Unified_IO::Local::Shell::DSL
    include Unified_IO::Remote::SSH::DSL
    include Checked::DSL::Racked
    include Base
    attr_accessor :path

    SERVER_METHODS = %w{ servers server groups group }
    
    attr_writer *SERVER_METHODS
    SERVER_METHODS.each { |meth|
      eval %~
        def #{meth}
          raise "No set: :#{meth}" unless instance_variable_defined?(:@#{meth})
        end
      ~
    }
    
    def ssh_run *args
      begin
        super
      rescue Timeout::Error => e
        raise e.class, server.inspect
      rescue Net::SSH::HostKeyMismatch => e
        if e.message[%r!fingerprint .+ does not match for!]
          remove_rsa_host_key
          raise Uni_Mind::Retry_Command, "Removed the RSA key."
        end
      end
    end

    def remove_rsa_host_key
      shell "ssh-keygen -f \"#{File.expand_path "~/.ssh/known_hosts"}\" -R #{server[:ip]}"
    end

  end # === module Arch
  
  extend Class_Methods
  include Arch
  
  def initialize path
    @path = path

  end
  
  def fulfill_request
    pieces = path.split('/')
    ns     = pieces('/')[0,2].join('/')
    meth   = pieces[2, 1]
    args   = pieces[3, pieces - 3]
      
    klasses = self.class.middleware.select { |klass|
      klass.const_defined?(:Map) && [ns, '/*'].include?(klass::Map)
    }
    
    if args.empty?
      raise ArgumentError, "No middleware found for: #{path}, using namespace: #{ns}"
    end
    
    meths = []
    klasses.each { |k|
      app = k.new(path)
      meths.<< begin
                 app.request! meth, *args
                 :request!
      rescue NoMethodError => e
        raise e unless e['undefined method `request!']
        begin
          app.public_send meth, *args
          meth
        rescue NoMethodError => e
        end
      end
    }
    
    raise Not_Found, path if meths.empty?
  end

  
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
