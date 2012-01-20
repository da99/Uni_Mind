require "Uni_Mind/version"
require "Uni_Arch"
require "Unified_IO"
require 'Checked'

require 'Uni_Mind/Template_Dir'
require "Uni_Mind/Inspect"
require "Uni_Mind/Templates"

class Uni_Mind

  module Arch

    include Uni_Arch::Arch

    include Uni_Mind::Inspect
    include Uni_Mind::Templates
    
    def initialize *args
      super
      self.server = env.server if env[:server]
      
      if Unified_IO::Remote::Server.group?(env.klass.name)
        env.create 'group', Unified_IO::Remote::Server_Group.new(env.klass.name)
        env.create 'servers', env.group.servers
      elsif Unified_IO::Remote::Server.server?(env.klass.name)
        env.create 'server',  Unified_IO::Remote::Server.new( env.klass.name )
      end
    end

  end # === module Arch
  
  include Uni_Arch::Arch

end # === class Uni_Mind


%w{ groups servers }.each { |cat|
  %w{ Uni_Arch uni_arch Uni_Mind uni_mind }.each { |uni|
    Dir.glob("configs/#{cat}/*/#{uni}.rb").each { |file|
      require File.expand_path(file).sub(".rb", '')
    }
  }
}
