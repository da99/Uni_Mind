
    
class Uni_Mind
module Recipes

  class Thin
    
    include Uni_Arch::Base

  def thin_start
    shell "thin -s1 -p 3001 start"
  end
  
  def thin_stop
    shell "thin -s1 -p 3001 stop"
  end

end # === module Thin
  end # === module Recipes
end # === class Uni_Mind
