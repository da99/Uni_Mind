require "Uni_Mind/version"
require 'Sin_Arch'
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'
require 'Uni_Mind/Template_File'


class Uni_Mind
  
  Wrong_IP         = Class.new(RuntimeError)
  Server_Not_Found = Class.new(RuntimeError)
  Retry_Command    = Class.new(RuntimeError)

  module Arch

    include Unified_IO::Local::Shell::DSL
    include Unified_IO::Remote::SSH::DSL
    include Checked::DSL::Racked

    def self.included klass
      klass.send :include, Sin_Arch::Arch
    end

    def ssh_connect
      ssh
    end

    def ssh
      @ssh_valid ||= begin
                       ssh!.connect(server)
                       true
                     end
      super
    end
    
    %w{ servers server groups group }.each { |meth|
      eval %~
        def #{meth}
          request.env['#{meth}']
        end
      ~
    }

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
