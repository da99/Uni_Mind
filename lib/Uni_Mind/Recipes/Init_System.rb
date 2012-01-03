
class Uni_Mind
  module Recipes
    class Init_System

      include Uni_Arch::Base
      include Uni_Mind::Base

      route '/!w/uptime/'
      def uptime
        results = record_stdout {
          ssh('uptime')
        }

        demand(results.output) { |v|
          v.contain! %r!load average: \d+\.\d+, \d+\.\d+, \d+\.\d+!
        }
        
        puts results.output
      end

      def ensure_arch_linux
        info = ssh.silent("uname -a")

        if !info[' x86_64 ']
          yell "OS is not 64 bit: "
          yell info
          abort
        end

        # Make sure arch-release file exists.
        ssh.silent("cat /etc/arch-release")
        server.os_name = 'ArchLinux'

      end # === def ensure_arch_linux

      def extend_with_os 
        # Include ArchLinux lib files
        Dir.glob("#{File.dirname __FILE__}/os/#{server.os_name}/*.rb").map { |file|
          require clean(file, :chop_rb)
          extend Uni_Mind.const_get(clean(file, :ruby_name))
        }
      end

      route '/!w/about/'
      def about_system
        sudo(%@ 
          uname -a 
          uname -o 
          arch 
        @)
      end

      def init_testing
        raise(":init_testing is not allowed.") unless root_login?

        upload_authorized_key('temp.root')
        install_sshd_config( 'root.sshd_config.sh' )

        flush_iptables

        sudo(%@ 

           iptables -A INPUT  -p tcp --dport 22 --syn -m limit --limit 1/m --limit-burst 20 -j ACCEPT
           iptables -A INPUT  -p tcp --dport 22 --syn -j DROP

           iptables -P INPUT DROP
           iptables -P FORWARD DROP
           iptables -P OUTPUT ACCEPT

           iptables -A INPUT -j DROP
           iptables -I FORWARD -m state --state INVALID -j DROP
           iptables -I OUTPUT  -m state --state INVALID -j DROP  

        @)

        save_iptables
      end # == def init_testing

      def upgrade_system

        reset_pacman_mirror_list

        sudo(%@
      pacman-db-upgrade
      pacman -S initscripts
    @)

    install_iptables
    install_pacnews
    install_git

    setup "https://wiki.archlinux.org/index.php/SHA_password_hashes"

      end # === def upgrade_system

      def install_sha512

        far_file "/etc/pam.d/passwd" do
          update_line( %r!^password\s+required!, :unique, :must_exist ) {

            substitute_word 'md5', 'sha512', :unique, :optional
            append_word "rounds=65536", :unique  
            just_one %r!rounds=\d+!

          }
        end

        far_file "/etc/default/passwd" do

          update_line( 'CRYPT=des', :unique, :optional) {
            with "CRYPT=sha512"
          }

          line_must_exist 'CRYPT=sha512'
        end

        far_file '/etc/login.defs' do
          add_line( "ENCRYPT_METHOD SHA512", :unique )
        end

        at_exit {
          notify "SHA512 has been installed. Update passwords to rehash."
        }

      end # === def install_sha512

      def install_git
        sudo(%^
      pacman -S git
      git config --global user.name "da99" !
      git config --global user.email "do_not_contact_me@mailinator.com" !
      git config --global color.ui true
    ^)
      end

      # Mirror list: http://www.archlinux.org/mirrors/status/#successful 
      def reset_pacman_mirror_list
        local_and_far_files "templates/pacman.mirror.list.sh", "/etc/pacman.d/mirrorlist" do
          upload
        end
      end

      def pacnews
        cleaner( ssh('egrep "pacnew" /var/log/pacman.log') ) { |q|
          q.file_names_by_ext '.pacnew' 
        }
      end

      def list_pacnews
        puts pacnews.map(&:first)
      end

      def install_pacnews

        command = ''

        ssh %@ mkdir -p ~/.backups @

        pacnews.each { |file, base|

          next if base['sshd_config'] || base['rc.conf']

          sudo(%@
        [ -f #{file} ] 
        cp #{base} ~/.backups/#{base.gsub('/', ',')}.#{Time.now.to_i}
        mv -f #{file} #{base}
      @) do |ch, data|
        case ch[:status]
        when 0
          # do nothing
        else
          if data.strip == ''
          else
            handle_exit_status ch, data
          end
        end
      end

        }

        sudo("pacman-db-upgrade")
        add_iptables_daemon

      end  # === def install_pacnew_configs

    end # === module
  end # === module Recipes
end # === class Uni_Mind
