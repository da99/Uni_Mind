require 'yaml'
require "Uni_Arch"
require "Uni_Mind/version"
 
class Uni_Mind

  module Group
    module Arch
      include Uni_Arch::Arch
    end
  end

  module Server
    module Arch
      include Uni_Arch::Arch
    end
  end
  
  module Arch
    include Uni_Arch::Arch
  end # === module Arch
    
  include Uni_Arch::Arch

end # === class Uni_Mind

# Modules
require 'Uni_Mind/Templates'
require 'Uni_Mind/Group'
require 'Uni_Mind/Server'
require 'Uni_Mind/Sinatra'

# Classes
require 'Uni_Mind/Template_Dir'
require 'Uni_Mind/Apps'
require 'Uni_Mind/App'
require "Uni_Mind/All"


