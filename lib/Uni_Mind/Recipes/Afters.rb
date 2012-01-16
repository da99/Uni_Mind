
class Uni_Mind
  class Recipes
    class Afters
      
      include Unified_IO::Remote::SSH::DSL
    
      def initialize app
        @app = app
      end
      
      def call env
        arr = @app.call env
        ssh!.disconnect
        arr
      end

      def save_pending_templates

        if Dir.exists?('.git') && %x! git status ![/ \+configs\/servers\/.+\/templates\/pending/]
          puts %x! 
          git reset
          git add configs/servers/*/templates/*
          git commit -m "Backed up files from server."
        !.strip.split("\n").join(' && ')
        end

      end 
      
    end # === class Afters
  end # === class Recipes
end # === class Uni_Mind
