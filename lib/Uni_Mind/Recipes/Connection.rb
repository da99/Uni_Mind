

class Uni_Mind
  module Recipes

  class Connection

    include Uni_Arch::Base
    include Unified_IO::Local::Shell::DSL

    attr_accessor :ssh_connection
    attr_reader :server, :remote
    
    def as_root 
      remotely { 
        yield
      }
    end # === def as_root

    def setup_root
      
      remotely { 
        
        # Ensure no one else is connected to server
        # since this is a newly built one.
        output = ssh( %@ ps aux | grep ssh @ ).strip
        if output.split("\n").size > 4
          raise "Too many ssh processes: #{output}"
        end
        
        system_upgrade
        
        # Look down certain dirs/files.
        #
        # From: https://wiki.archlinux.org/index.php/Security#Filesystem_permissions
        cmd << %@ 
          chmod 700 /boot /etc/iptables
          [ -d /etc/arptables ] && chmod 700 /etc/arptables
        @
        
        ssh cmd
        
        #
        # Create the first user.
        # 
        useradd server[:user]
        
        local_and_far_files( '~/.ssh/mu', "/home/#{server[:user]}/.ssh/authorized_keys" ) { 
          
          ssh %@
            mkdir -p  "/home/#{server[:user]}/.ssh"
            touch #{far}
            chown #{server[:user]}:#{server[:user]} #{far}
            chmod go-rwx -R "/home/#{server[:user]}/.ssh"
          @
            
          append_to_file 
        
        }
        
        
        local_and_far_files('templates/ssh_config.txt', '/etc/ssh/sshd_config') { 
          
          files_dont_match do
            ssh %@
              iptables -I INPUT  -p tcp --dport #{env.server[:port]} -j ACCEPT
              iptables -I OUTPUT -p tcp --sport #{env.server[:port]} -j ACCEPT
            @
            
            case env.server.os_name
            when 'ArchLinux'
              ssh %@
                nohup sh -c "sleep 2 && rc.d restart sshd" &
              @
            else
              ssh %@
                nohup sh -c "sleep 2 && service sshd restart" &
              @
            end
          end
          
        }
      
      } # === end remotely
      
      # Instantly print to the screen: 
      # http://mattberther.com/2009/02/11/puts-vs-print-in-ruby
      STDOUT.sync = true
      print "\n\nWaiting for sshd restart"
      2.times do |i|
        print "."
      end
      
      shell.tell "\n\nLogging in as #{server[:user]}..."
      
      remotely { 
        setup_iptables
      }
      
      notify "Reboot the system."
      
    end # === setup_root
    
    # 
    # From: http://thinkingdigitally.com/archive/capturing-output-from-puts-in-ruby/
    #
    def record_stdout
      out = StringIO.new
      $stdout = out
      results = yield
      $stdout = STDOUT

      str_out = begin
                  out.rewind
                  str = out.readlines.join
                  out.rewind
                  str
                end

      return Args.new(:stdout => out, :output => str_out, :results => results)
    ensure
      $stdout = STDOUT
      
      out.rewind
      shell.tell *out.readlines
    end

    def test_pty_as_root

      notify "Running command regularly: #{ARGV[1].inspect}"
      as_root {

      new_channel = ssh_connection.open_channel do |channel|
        
        
        channel.on_data { |ch2, data|
          shell.tell data 
          
          if data[ %r!\[y/N\]!i ] 
            STDOUT.flush  
            ch2.send_data( STDIN.gets.chomp + "\n" )
          end
        }

        channel.on_extended_data { |ch2, type, data|
          
          if data[ %r!\[y/N\]!i ] 
            STDOUT.flush  
            ch2.send_data( STDIN.gets.chomp + "\n" )
          else
            yell "Type: #{type}\n#{data}"
            abort 'Aborting...'
          end
          
        }

        channel.exec(ARGV[1]) { |ch2, success|
          if not success
            yell("Could not execute: #{ARGV[1]}") 
            abort 'Aborting...'
          end
        }

      end

      new_channel.wait

      }
      
      notify "Now re-running command with 'pty': #{ARGV[1].inspect}"
      as_root {
        ssh ARGV[1]
      }
    
    end

    def eval_as_root
      as_root {
        ssh_connection.exec!(ARGV[1]) { |ch, stream, data|
          shell.tell "#{stream.inspect}"
          shell.tell "#{data}"
        }
      }
    end

    def root_login?
      env.server.login == 'root'
    end


  end # === module Connection
  
  end # === module Recipes
end # === class Uni_Mind
