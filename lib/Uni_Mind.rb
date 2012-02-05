require 'yaml'
require "Uni_Arch"
require "Uni_Mind/version"

class Uni_Mind

  include Uni_Arch::Arch
  
  module Arch
    
    include Uni_Arch::Arch
    
    def initialize *pieces
      new_pieces = pieces.map { |obj|
        case obj
        when '*'
          'All'
        when String
          obj.split('/').map { |str| str == '*' ? 'All' : str }.join('/')
        else
          obj
        end
      }
      
      super(*new_pieces)
    end

    def thin_config *args
      Uni_Mind::App.thin_config *args
    end
    
  end # === module Arch
  
  module Group
    include Uni_Arch::Arch
  end

  module Server
    include Uni_Arch::Arch
  end
    
  include Uni_Arch::Arch

end # === class Uni_Mind

# Modules
require 'Uni_Mind/Templates'
require 'Uni_Mind/Server_Group'
require 'Uni_Mind/Server'

# Classes
require 'Uni_Mind/Template_Dir'
require 'Uni_Mind/Apps'
require 'Uni_Mind/App'
require "Uni_Mind/All"


