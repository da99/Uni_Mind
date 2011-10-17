
class Uni_Mind
module Recipes
module Init_System_Test

  def test_uptime
    results = record_stdout {
      user_action
    }
    
    demand(results.output) { |v|
      v.contain! %r!load average: \d+\.\d+, \d+\.\d+, \d+\.\d+!
    }
  end

end # === module Init_System_Test
end # === module Recipes
end # === class Uni_Mind
