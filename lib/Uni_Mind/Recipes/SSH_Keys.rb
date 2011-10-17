
class Uni_Mind
  module Recipes

  module SSH_Keys

  def upload_authorized_key name
    local_and_far_files "~/.ssh/#{name}", "~/.ssh/authorized_keys" do
      if !far_c || !far_c[local_c]
        ssh %@
          mkdir -p ~/.ssh
          echo -e #{local_c.inspect} >> #{far}
          chmod 700 ~/.ssh
          chmod 600 #{far}
        @
      end
    end
  end # === def upload_authorized_key

  # Create keys for a user.
  def create_ssh_keys

    ssh_loc = lambda { |str| File.join('~/.ssh', str) }

    user = ARGV[1]
    raise "File name is not defined." unless user

    names = []
    names << (priv = "#{user}.private")
    names << (pub  = "#{user}.pub")
    names << (base = "#{user}")

    files = names.map { |str| ssh_loc.call(str) }

    # Make sure we don't overwrite existing files.
    files.each do |old_file|
      if File.file?( old_file )
        raise( "Can't overwrite existing file: #{old_file}" )
      end 
    end 

    sh "ssh-keygen -t rsa -f #{ssh_loc.call base}"

    sh "mv #{ssh_loc.call  base }     #{ssh_loc.call base  }.private"
    sh "mv #{ssh_loc.call  base }.pub #{ssh_loc.call base  }"  
    sh "chmod 700 ~/.ssh"

    [base, priv].each do | str |
      sh "chmod 600 #{ssh_loc.call str}"
    end 
  end # === def create_ssh_keys

  def remove_rsa_host_key
    shell "ssh-keygen -f \"#{File.expand_path "~/.ssh/known_hosts"}\" -R #{server[:ip]}"
  end

  def restart_sshd 
    case server.os_name
    when 'ArchLinux'
      sudo(" rc.d restart sshd ", :exits=>[0,127]) { |ch, data|
        case ch[:status]
        when 0
          # do nothing
        when 127
          sudo " /etc/rc.d/sshd restart "
        else
          handle_exit_status ch, data
        end
      }
    else
      ssh " service sshd restart "
    end
  end # === def restart_sshd

  def install_sshd_config key = nil
    key ||= 'sshd_config.txt'
    local_and_far_files "templates/#{key}", "/etc/ssh/sshd_config" do
      upload
      restart_sshd
    end
  end # === def install_sshd_config

  end # === module SSH_Keys
  end # === module Recipes
end # === class Uni_Mind
