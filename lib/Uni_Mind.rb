require "Uni_Mind/version"
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'
require 'Uni_Mind/Template_File'


# ====================================================
#
# Create a temp dir and delete it at exit.
#
# puts %x! mkdir -p /tmp/Remotely !
# 
# at_exit { 
#   %x! rm -rf /tmp/Remotely ! 
#   
#   if Dir.exists?('.git') && %x! git status ![/ +backups\\//]
#     puts %x! 
#       git reset
#       git add backups/*
#       git commit -m "Backed up files from server."
#     !.strip.split("\\n").join(' && ')
#   end
# 
#   puts ""
#   puts ""
# }
# ====================================================



class Uni_Mind
  
  Server_Not_Found = Class.new(RuntimeError)
  Wrong_IP = Class.new(RuntimeError)
  
  extend Checked::Clean::DSL

  Dir.glob("#{File.dirname __FILE__}/Uni_Mind/Recipes/*.rb").map { |raw_file|
    name = clean(raw_file, :ruby_name)
    require "Uni_Mind/Recipes/#{name}"
    include Uni_Mind::Recipes.const_get(name)
  }
  # =====================================================
  
  module Class_Methods
    
    def run group, method, args, opts
      server_count = 0

      Dir.glob('configs/servers/*/config.rb').each { |file|

        name = file[%r!/([^/]+)/config.rb!] && $1
        server = Unified_IO::Remote::Server.new( name, opts )
        applicable = begin
                       group == 'ALL' || 
                         server.group == group || 
                         server.hostname == group
                      end
        
        next unless applicable
        
        server_count += 1
        mind = Uni_Mind.new( server )
        mind.setup_and_run( method, args )

      }
      
      if server_count === 0
        raise Server_Not_Found, "#{group}"
      end
    end
    
  end # === module Class_Methods
  
  extend Class_Methods
  include Checked::Demand::DSL
  include Checked::Clean::DSL
  include Unified_IO::Local::Shell::DSL
  include Unified_IO::Remote::SSH::DSL

  attr_reader :run_count, :server, :method_name, :args

  def initialize new_server

    @server = new_server
    
    require File.expand_path("configs/groups/#{server.group}/base.rb")
    extend Uni_Mind.const_get(server.group)
    
  end # === def initialize
  
  def setup_and_run  method_name, args
    @method_name    = method_name
    @args           = args
    @run_count      = 0
    
    unless respond_to?(method_name) && public_methods.include?(method_name.to_sym)
      raise "Unknown method_name: #{method_name.inspect}" 
    end
    
    begin

      send "test_#{method_name}"

      if run_count != 1
        raise "Not called: #{action} count: #{@run_count}" 
      end
        
    rescue Timeout::Error => e
      raise e, server.inspect
      
    rescue Net::SSH::HostKeyMismatch => e
      if e.message[%r!fingerprint .+ does not match for!]
        remove_rsa_host_key
        shell.notify "Removed the RSA key."
        shell.notify "Re-try your command."
        abort
      end
      
      raise e
    end

    ssh!.disconnect
  end # === def setup

  def ssh_connect
    ssh
  end

  def ssh
    @ssh_valid ||= begin
                     ssh!.connect(server)
                     true
                   end
    super
  end

  def run
    if run_count > 0
      raise "Action called more than once: #{action} #{run_count}" 
    end

    results = send( method_name, *args )

    @run_count += 1
    results
  end
  
end # === class Uni_Mind


__END__



  def validate_test_methods
    test_meths = methods.grep(%r!^test_!).map(&:to_s)
    test_meths.each { |meth|
      orig = test_meths.detect { |orig| 
        meth[orig]
      }
      
      if !orig
        raise "Original method not found for: #{meth}"
      end
    }
  end
