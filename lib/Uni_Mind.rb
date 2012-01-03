require "Uni_Mind/version"
require 'Uni_Arch'
require 'Checked'
require 'Unified_IO'

require 'Uni_Mind/Template_Dir'
require 'Uni_Mind/Template_File'




class Uni_Mind
  
  Server_Not_Found = Class.new(RuntimeError)
  Wrong_IP = Class.new(RuntimeError)
  
  include Uni_Arch::Base
  include Checked::Demand::DSL
  include Checked::Clean::DSL
  include Unified_IO::Local::Shell::DSL
  include Unified_IO::Remote::SSH::DSL
  
  Dir.glob("#{File.dirname __FILE__}/Uni_Mind/Recipes/*.rb").map { |raw_file|
    name = clean(raw_file, :ruby_name)
    require "Uni_Mind/Recipes/#{name}"
    use Uni_Mind::Recipes.const_get(name)
  }
  # =====================================================

  before
  def grab_uni_archs
    %w{ groups servers }.each { |cat|
      Dir.glob("configs/#{cat}/*/uni_arch.rb").each { |file|
        require File.expand_path(file)
      }
    }
  end

  before
  def set_server
    server_name = request.path.info.split('/')[1]
    return unless server_name
    request.env.create :server, Uni_Mind.new( server_name )
  end
  
  route "/ALL/!w action!/!* splat!/"
  def to_all_servers
    server_count = 0

    Dir.glob('configs/servers/*/config.rb').each { |file|

      name = file[%r!/([^/]+)/config.rb!] && $1
      server = Unified_IO::Remote::Server.new( name )

      mind = Uni_Mind.new( request.path.info.sub('/ALL/', "/#{server.name}/") )
      begin
        mind.fulfill_request
        server_count += 1
      rescue Uni_Arch::No_Route_Found
      end
      
    }

    if server_count.zero?
      raise Server_Not_Found, request.path.info.inspect
    end
  end
  
  before
  def rescue_errors
    
    begin

      request.continue

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

  module Base

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

    def save_pending_templates

      if Dir.exists?('.git') && %x! git status ![/ \+configs\/servers\/.+\/templates\/pending/]
        puts %x! 
          git reset
          git add configs/servers/*/templates/*
          git commit -m "Backed up files from server."
        !.strip.split("\n").join(' && ')
      end

    end

  end # === module Base
  
  include Base
  
end # === class Uni_Mind


