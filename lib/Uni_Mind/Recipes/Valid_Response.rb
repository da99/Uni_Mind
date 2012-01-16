
class Uni_Mind
  class Recipes
    class Valid_Response
      
      def initialize app
        @app = app
      end # === def initialize app
      
      def call env
        arr = @app.call(env)
        raise "Invalid response: #{arr}" unless arr.is_a?(Array) && arr.size == 3
        raise "Invalid body: #{arr.last}" unless arr.last.respond_to?(:each)
        arr
      end # === def call env
      
      
      
    end # === class Valid_Response
    
  end # === class Recipes
  
end # === class Uni_Mind
