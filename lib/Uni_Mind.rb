require 'yaml'
require "Uni_Mind/version"
require "Uni_Arch"

require 'Uni_Mind/Template_Dir'

class Uni_Mind

  MODS = %w{ Inspect Templates}
  include Uni_Arch::Arch
  
  module Arch

    include Uni_Arch::Arch

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

%w{ group server }.each { |type|
  
  Dir.glob("#{type}s/*/Uni_Mind.rb").each { |path|
    
    klass_name = File.basename( File.dirname(path) )
    require File.expand_path( "#{type}s/#{klass_name}/Uni_Mind" )
    
    eval %~
      class #{klass_name}
        include "Uni_Mind::#{type.capitalize}::Base"
      end
    ~, nil, __FILE__, __LINE__ - 3
    
  }
  
}

