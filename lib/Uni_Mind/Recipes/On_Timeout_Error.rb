
class Uni_Mind
  class Recipes
    class On_Timeout_Error
      
      def initialize(app)
        @app = app       
      end                

      def call(env)      
        begin
          @app.call(env)   
        rescue Timeout::Error => e
          raise env['server'].inspect
        end
      end                
      
    end # === class On_Timeout_Error

    
  end # === class Recipes
  
end # === class Uni_Mind
