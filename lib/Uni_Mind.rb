require "Uni_Mind/version"
require "Uni_Arch"

require 'Uni_Mind/Template_Dir'

class Uni_Mind

  MODS = %w{ Inspect Templates}
  include Uni_Arch::Arch
  
  module Arch

    include Uni_Arch::Arch

    def initialize *args
      super
      
      k = request.klass.name
      [ k, k.downcase, k.capitalize, k.upcase ].detect { |s_name| 
        
        if Unified_IO::Remote::Server.group?(s_name)
          
          env.create 'group',   Unified_IO::Remote::Server_Group.new( s_name )
          env.create 'servers', env.group.servers
          request.klass.send( :include, Uni_Mind::Group ) #unless request.klass.included_modules.include?(Uni_Mind::Group)
          true
          
        elsif Unified_IO::Remote::Server.server?( s_name )
          
          env.create 'server',  Unified_IO::Remote::Server.new( s_name )
          extend Uni_Mind::Server
          self.server = env.server
          true
          
        end
        
      }
      
    end

  end # === module Arch
end # === class Uni_Mind

Uni_Mind::MODS.each { |mod| require "Uni_Mind/#{mod}" }
require 'Uni_Mind/Server'
require 'Uni_Mind/Group'
require "Uni_Mind/ALL"

%w{ groups servers }.each { |cat|
  %w{ Uni_Arch uni_arch Uni_Mind uni_mind }.each { |uni|
    Dir.glob("configs/#{cat}/*/#{uni}.rb").each { |file|
      require File.expand_path(file).sub(".rb", '')
    }
  }
}

