
class Uni_Mind
  class Recipes
    class On_RSA_Key_Mismatch
      
      def initialize app
        @app = app
      end # === def initialize app
      
      def call env
        begin
          @app.call env
        rescue Net::SSH::HostKeyMismatch => e
          if e.message[%r!fingerprint .+ does not match for!]
            remove_rsa_host_key
            raise Uni_Mind::Retry_Command, "Removed the RSA key."
          end
        end
      end
      
      def remove_rsa_host_key
        shell "ssh-keygen -f \"#{File.expand_path "~/.ssh/known_hosts"}\" -R #{server[:ip]}"
      end
      
    end # === class On_RSA_Key_Mismatch
    
  end # === class Recipes
  
end # === class Uni_Mind
