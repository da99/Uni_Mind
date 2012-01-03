
class Uni_Mind

  module Recipes

  class Shell
    
    include Uni_Arch::Base

    # vi: http://kb.iu.edu/data/afdc.html
    def useradd new_user
      home  = "/home/#{new_user}"
      exrc  = "#{home}/.exrc"
      vimrc = "#{home}/.vimrc"

      ssh( %@egrep -i "^#{new_user}:" /etc/passwd@ ) do |ch, data|
        case ch[:status] 
        when 0
        when 1
          sudo %@
           useradd --create-home #{new_user}

           chmod o-rwx /home/#{new_user}

           echo "set number"     >> #{exrc}
           echo "set autoindent" >> #{exrc}
           echo "set ignorecase" >> #{exrc}

           chown #{new_user}:#{new_user} #{exrc}

           cat #{exrc} >> #{vimrc}
           chown #{new_user}:#{new_user} #{vimrc}
        @
        else
          handle_exit_status ch, str
        end
      end
    end

    def handle_exit_status ch, str, exits = nil
      exits ||= [0]
      return true if exits.include?(ch[:status])

      if str.strip[%r^Starting full system upgrade...\s+there is nothing to do\z^]
        # Everything is fine.
      else
        notify "Allowed exit statuses: #{exits.inspect}"
        yell "Exit status: #{ch[:status]}\n#{str}"
        yell 'Aborting...'
        abort 
      end
    end
      
  end # === module Shell
  end # === module Recipes

end # === class
