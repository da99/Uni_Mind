require 'yaml'
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
          self.server env.server
          true
          
        end
        
      }
      
    end

  end # === module Arch
  
  def thin_config *args
    Uni_Mind::App.thin_config *args
  end

end # === class Uni_Mind

Uni_Mind::MODS.each { |mod| require "Uni_Mind/#{mod}" }
require 'Uni_Mind/Apps'
require 'Uni_Mind/App'
require 'Uni_Mind/Server_Group'
require 'Uni_Mind/Server'
require 'Uni_Mind/Group'
require "Uni_Mind/ALL"

%w{ groups servers }.each { |type|
  Dir.glob("#{type}/*/Uni_Mind.rb").each { |path|
    require File.expand_path(path.sub('.rb',''))
  }
}

