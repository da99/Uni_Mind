require "Uni_Mind/version"
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'


class Uni_Mind
  
  Wrong_IP         = Class.new(RuntimeError)
  Server_Not_Found = Class.new(RuntimeError)
  Retry_Command    = Class.new(RuntimeError)
  Not_Found        = Class.new(RuntimeError)
  Frozen           = Class.new(RuntimeError)

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

    SERVER_METHODS = %w{ servers server groups group }
    
    attr_accessor :path
    attr_reader   :env

    attr_writer *SERVER_METHODS
    SERVER_METHODS.each { |meth|
      eval %~
        def #{meth}
          raise "Not set: :#{meth}, env: \#{env.inspect}" unless env.has_key?('#{meth}') && env['#{meth}']
          env['#{meth}']
        end
      ~
    }
    
    def initialize path
      @path = path
      @env  = {}
    end
    
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
  
  attr_reader :methods
  
  def initialize *args
    @methods = []
    super
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
    env = {}
    klasses.each { |k|
      app = k.new(path)
      app.env.merge! env
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
      
      env.merge!(app.env)
    }
    
    raise Not_Found, path if methods.empty?
    
    freeze
    result
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
