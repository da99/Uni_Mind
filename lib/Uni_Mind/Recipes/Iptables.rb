
class Uni_Mind
  module Recipes

  module Iptables

  def install_iptables
    sudo(" pacman -S iptables ")
  end
  
  def __reset_rc_conf
    templ = "templates/rc.conf"
    rc    = "/etc/rc.conf"
  
    shell %@ touch #{templ} @
    local_and_far_files templ, rc do
      
      d_lines = far_c.split("\n").select {|line| line[/^DAEMONS/] }
      raise "Daemon line not found: #{d_lines.inspect}" if d_lines.size < 1
      raise "Too many lines with daemons: #{d_lines.inspect}" if d_lines.size > 1
      
      daemon = d_lines.first
      
      meths = %w{ iptables sshd }
      new_lines = far_c.split("\n").map { |line|
          if line == daemon 
            
            updated = line 

            if !line[ /[\(\s]iptables[\s\)]/  ]
              updated = line.sub(/[\(\s]network[\s\)]/) { |string|
                string.sub('network', ' iptables network ')
              }
            end
            
            if !line[ /[\(\s]sshd[\s\)]/  ]
              updated = line.sub( ')', ' sshd )' )
            end
            
            updated
          else
            line
          end
      }

      File.open( templ, 'w' ) { |io|
        io.write new_lines.join("\n")
      }
      
      upload
      
    end
  end

  def reset_iptables
    root_login? ? reset_root_iptables : reset_user_iptables
  end

  #
  # Flush all rules, making sure default rule is not to drop package:
  # http://www.linuxweblog.com/iptables-flush
  # http://www.cyberciti.biz/faq/flush-iptables-ubuntu-linux/ 
  # 
  # Drop attack attempt packets: http://newartisans.com/2007/09/neat-tricks-with-iptables/
  # 
  # * Allow traffic to established connections:
  # 
  def flush_iptables
    
    sudo(%@
       pacman -Syu iptables

       iptables -P INPUT ACCEPT
       iptables -P FORWARD ACCEPT
       iptables -P OUTPUT ACCEPT
      
       iptables -F
       iptables -X
       iptables -t nat -F
       iptables -t nat -X
       iptables -t mangle -F
       iptables -t mangle -X
      
       iptables -P INPUT ACCEPT
       iptables -P FORWARD ACCEPT
       iptables -P OUTPUT ACCEPT
              
       iptables -I INPUT 1 -m state --state INVALID -j DROP 
       iptables -I INPUT 2 -p tcp -m tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
       iptables -I INPUT 3 -p tcp -m tcp --tcp-flags SYN,RST SYN,RST -j DROP
              
       iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    @)
    
  end
    
  def save_iptables
    case server.os_name
    when 'ArchLinux'
      sudo("/etc/rc.d/iptables save")
      if not ssh("cat /etc/rc.conf")[%r!^DAEMONS=\(.+ iptables network .+\)\s?$!]
        yell "Add iptables to DAEMONS in /etc/rc.conf "
        yell "See: https://wiki.archlinux.org/index.php/Iptables "
        abort
      end
    when 'CentOS' 
      sudo("service iptables save")
    else
      raise "Unknow OS: #{server.os_name.inspect}"
    end
  end
  
  def list_iptables
    sudo "iptables --list --line-numbers"
  end
  
    
    # Firewall:
    #   * Deleting: iptables -D INPUT N
    #   * Listing: iptables -L --line-numbers
    #   * Allow traffic too nginx.
    # 
    def setup_iptables

      port = ""
      str = ''
      
      reset_iptables 
      
      # * Allow loopback:
      str << %@
         iptables -A INPUT  -i lo  -s 127.0.0.1 -j ACCEPT 
      @

  
      # * Allow limited pinging: http://newartisans.com/2007/09/neat-tricks-with-iptables/
      str << %@
         iptables -A INPUT  -p icmp -m icmp --icmp-type address-mask-request -j DROP
         iptables -A INPUT  -p icmp -m icmp --icmp-type address-mask-reply -j DROP
         iptables -A INPUT  -p icmp -m icmp --icmp-type timestamp-request -j DROP
         iptables -A INPUT  -p icmp -m icmp -m limit --limit 1/second -j ACCEPT 
      @

      # * Prevent more then two connection attempts in 1 minute for ssh AND 
      # http://wiki.centos.org/HowTos/Network/SecuringSSH#head-a296ec93e31637aa349538be07b37f67d836688a

      str << %@
         iptables -A INPUT  -p tcp --dport #{server[:port]} --syn -m limit --limit 1/m --limit-burst 20 -j ACCEPT
         iptables -A INPUT  -p tcp --dport #{server[:port]} --syn -j DROP
      @

      # * Block all other traffic & save rules: http://wiki.centos.org/HowTos/Network/IPTables
      str << %@
         iptables -P INPUT DROP
         iptables -P FORWARD DROP
         iptables -P OUTPUT ACCEPT
      
         iptables -A INPUT -j DROP

         iptables -I FORWARD  -m state --state INVALID -j DROP

         iptables -I OUTPUT  -m state --state INVALID -j DROP  
         iptables -A OUTPUT  -o lo  -d 127.0.0.1 -j ACCEPT 
      
      @
      
      ssh.sudo(str)
      save_iptables

    end # === setup_iptables


end # === module Iptables
  end # === module Recipes
end # === class Uni_Mind

__END__



# def iptable_rule_number raw_str, single_line_required = true
#   
#   # Char list from : http://www.selectorweb.com/grep_tutorial.html
#   chars =  "? \\ / . [ ] ^ $".split.map { |c| Regexp.escape c }.join('|')
#   
#   grep_str = raw_str.gsub(%r!#{chars}!) do | match |
#     "\\\\#{match}"
#   end
#   
#   content = x_exec(%~ rake list_iptables | grep "#{grep_str}"~)
#   lines   = content.split("\\n").select { |l| l =~ /\\A\\d/ }
#   number = lines.first.to_i
#   
#   if single_line_required
# 
#     if lines.size > 1 
#       raise "Can't get line number for iptables because of too many results: #{lines.inspect}" 
#     end
# 
#     if lines.size < 1
#       raise "iptable rule not found for: #{raw_str.inspect}"
#     end
# 
#     if number < 2
#       raise "Found wrong rule for, #{raw_str.inspect}, #{content.inspect}"
#     end
#   
#   end
#   
#   number < 1 ? nil : number
# end
# 
# def iptable_rule_number? raw_str
#   !!iptable_rule_number(raw_str, false)
# end
# 
# IPTABLES_GREP = {}
# IPTABLES_GREP[:ssh_top] = "recent: SET name: ssh side: source"
# IPTABLES_GREP[:min_15]  = "tcp dpt:#{DEPLOYER.host_port} flags:FIN,SYN,RST,ACK/SYN limit: avg 1/min burst #{DEPLOYER.max_ssh_per_min}"
  # desc "Undoes the iptables:more_ssh."
  # task :less_ssh do
  #   # From: http://wiki.centos.org/HowTos/Network/SecuringSSH#head-a296ec93e31637aa349538be07b37f67d836688a
  #   num = iptable_rule_number(IPTABLES_GREP[:min_15])
  #   sh "sudo iptables -D INPUT #{num}"
  # end
# desc "Allow more connections on SSH."
# task :more_ssh do
#   # From: http://wiki.centos.org/HowTos/Network/SecuringSSH#head-a296ec93e31637aa349538be07b37f67d836688a
#   unless iptable_rule_number?(IPTABLES_GREP[:min_15])
#     num = iptable_rule_number(IPTABLES_GREP[:ssh_top])
#     sh "sudo iptables -I INPUT #{num+1} -p tcp --dport #{DEPLOYER.host_port} --syn -m limit --limit 1/m --limit-burst #{DEPLOYER.max_ssh_per_min} -j ACCEPT"
#   end
# end
  
