
class Uni_Mind
  
  module Server
    MODS.each { |m|
      include Uni_Mind.const_get(m.to_sym)::Server
    }
  end # === module Server
  
end # === class Uni_Mind
