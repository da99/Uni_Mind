require "Uni_Mind/version"
require "Uni_Arch"
require "Unified_IO"

require "Uni_Mind/Inspect"
require "Uni_Mind/Templates"

class Uni_Mind

  module Arch

    include Unified_IO::Local::Shell::DSL
    include Unified_IO::Remote::SSH::DSL
    include Uni_Mind::Inspect
    include Uni_Mind::Templates
    
    attr_reader :request, :env, :uni_mind
    def initialize uni_mind
      @uni_mind = uni_mind
      @env     = uni_mind.env
      @request = uni_mind.request
      self.server= env.server if env[:server]
    end
    
    def fulfill
      public_send env.method, *env.args
    end

  end # === module Arch
  
  include Arch
  
  module Base
    
    attr_reader :env, :request, :mind
    
    def initialize path
      @env = Uni_Arch::Env.new
      @request = req = Uni_Arch::Env.new
      
      req.create :path, path
      req.create :origin, Uni_Arch::Env.new
      req.origin.create :path, path
      
      kname, meth, args = path.gsub(%r!\A\/|\/\Z!, '').split('/')
      env.create :map,    "/#{kname}"
      env.create :method, meth
      env.create :args,   args
      
      klass = begin
                Uni_Mind.const_get kname.to_sym
              rescue NameError => e
                begin
                  Object.const_get kname.to_sym
                rescue NameError => e
                  begin
                    Object.const_get kname.upcase.map
                  rescue NameError => e
                    Object.const_get kname.split('_').map(&:capitalize).join('_').to_sym
                  end
                end
              end
      
      env.create :klass, klass

      if Unified_IO::Remote::Server.group?(env.kname)
        env.create 'group', Unified_IO::Remote::Server_Group.new(kname)
        env.create 'servers', env.group.servers
      elsif Unified_IO::Remote::Server.server?(kname)
        env.create 'server',  Unified_IO::Remote::Server.new( kname )
      end

      @mind= klass.new env, req
    end
    
    def set_servers
    end
    
  end # === module Base
  
  include Base
  
  module Class_Methods
    
    def request path
      u = new(path)
      u.mind.fulfill
    end
    
  end # === module Class_Methods
  
  extend Class_Methods
  
end # === class Uni_Mind

require 'Uni_Mind/Template_Dir'

%w{ 
  Befores 
  ALL 
  Templates
}.each { |name|
  require "Uni_Mind/Recipes/#{name}"
  Uni_Mind.use Uni_Mind::Recipes.const_get(name.to_sym)
}

%w{ groups servers }.each { |cat|
  %w{ Uni_Arch uni_arch Uni_Mind uni_mind }.each { |uni|
    Dir.glob("configs/#{cat}/*/#{uni}.rb").each { |file|
      require File.expand_path(file).sub(".rb", '')
    }
  }
}
