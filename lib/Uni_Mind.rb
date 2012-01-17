require "Uni_Mind/version"
require 'Sin_Arch'
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'


class Uni_Mind
  
  Wrong_IP         = Class.new(RuntimeError)
  Server_Not_Found = Class.new(RuntimeError)
  Retry_Command    = Class.new(RuntimeError)

  module Base
    
    %w{ servers server groups group }.each { |meth|
      eval %~
        def #{meth}
          request.env['#{meth}']
        end
      ~
    }
    
  end # === module Base
  
  module Arch

    include Unified_IO::Local::Shell::DSL
    include Unified_IO::Remote::SSH::DSL
    include Checked::DSL::Racked
    include Base

    def self.included klass
      klass.send :include, Sin_Arch::Arch
    end
    
  end # === module Arch
  
  include Arch

  use Rack::ContentLength
  
  class App 
    include Sin_Arch::App
  end
  
end # === class Uni_Mind

%w{ 
  Valid_Response
  Afters
  Befores 
  ALL 
  On_Timeout_Error 
  On_RSA_Key_Mismatch
  Templates
}.each { |name|
  require "Uni_Mind/Recipes/#{name}"
  Uni_Mind.use Uni_Mind::Recipes.const_get(name.to_sym)
}



Dir.glob("configs/**/uni_mind.rb").each { |file|
  require File.expand_path( file.sub('.rb', '') )
}
