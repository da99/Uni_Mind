require 'yaml'
require "Uni_Mind/version"
require "Uni_Arch"

require 'Uni_Mind/Template_Dir'

class Uni_Mind

  include Uni_Arch::Arch
  
  module Arch

    include Uni_Arch::Arch

  end # === module Arch
  
  module Base
    
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
    
  end # === module Base
  
  include Base

end # === class Uni_Mind

require 'Uni_Mind/Templates'
require 'Uni_Mind/Apps'
require 'Uni_Mind/App'
require 'Uni_Mind/Server_Group'
require 'Uni_Mind/Server'
require "Uni_Mind/All"

%w{ group server }.each { |type|
  
  namespace = ['server', type].uniq.map(&:capitalize).join('_')
  Dir.glob("#{type}s/*/Uni_Mind.rb").each { |path|
    
    klass_name = File.basename( File.dirname(path) )
    require File.expand_path( "#{type}s/#{klass_name}/Uni_Mind" )
    
    eval %~
      class #{klass_name}
        include Uni_Mind::#{namespace}::Base
      end
    ~, nil, __FILE__, __LINE__ - 3
    
  }
  
}

