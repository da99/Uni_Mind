require "Uni_Mind/version"

require 'Uni_Mind/Template_Dir'
require 'Uni_Mind/Template_File'

require 'Checked/Demand'
require 'Checked/Ask'

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

  Dir.glob("#{File.dirname __FILE__}/Uni_Mind/Recipes/*.rb").map { |raw_file|
    name = File.basename(raw_file.chop_rb)
    require "Uni_Mind/Recipes/#{name}"
    include Uni_Mind::Recipes.const_get(name)
  }
  # =====================================================
  
	module Class_Methods
		
		def run method, args, opts
			base_server = eval(File.read 'configs/base.rb' )

			Dir.glob('configs/servers/*/config.rb').each { |file|

				server = base_server.merge( eval(File.read file) )
				server[:hostname] = File.basename(File.dirname(file))

        server = Unified_IO::Server.new(server)
        if opts[:group] && server.group != opts[:group]
          next
        end
				Uni_Mind.new( server, method, args )

			}
		end
		
	end # === module Class_Methods
  
  Wrong_IP = Class.new(RuntimeError)
	extend Class_Methods
  include Checked::Demand::DSL
  include Checked::Clean::DSL
  include Unified_IO::Local::Shell::DSL
  include Unified_IO::Remote::SSH::DSL

  attr_reader :run_count, :server, :method_name, :args

  def initialize new_server, method_name, args

		@server         = new_server
		@method_name    = method_name
    @args           = args
		@run_count      = 0
		
    require File.expand_path("configs/groups/#{server.group}")
    extend Uni_Mind.const_get(server.group)
    unless respond_to?(action) && public_methods.include?(action.to_sym)
			raise "Unknown action: #{action.inspect}" 
		end
    
    begin
      ssh!.connect(server)
			
      hostname = ssh.run('hostname')
      if !( hostname == server.hostname )
        raise Wrong_IP, "HOSTNAME: #{hostname}, TARGET: #{server.hostname}, IP: #{server.ip}"
      end

			send "test_#{action}"

			if run_count != 1
				raise "Not called: #{action} count: #{@run_count}" 
			end
        
    rescue Net::SSH::HostKeyMismatch => e
      if e.message[%r!fingerprint .+ does not match for!]
        remove_rsa_host_key
        shell.notify "Removed the RSA key."
        shell.notify "Re-try your command."
        abort
      end
      
      raise e
    end

    Unified_IO::Remote::SSH.disconnect
  end # === def initialize
  
  def run
    if run_count > 0
      raise "Action called more than once: #{action} #{run_count}" 
    end

    results = send( action, args )

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
